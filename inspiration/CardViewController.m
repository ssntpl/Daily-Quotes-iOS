//
//  CardViewController.m
//  facebookSharing
//
//  Created by Sword Software on 03/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import "CardViewController.h"
#import "QuotesClass.h"
#import "BuyProVersionCardViewController.h"
#import "DBCore.h"

#define IMAGE_COUNT 36
#define SHARE_URL (@"http://www.ssntpl.com/daily-quotes-app/")

#define getImageWithId(s) [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg", s]]

@interface CardViewController (){
    NSInteger currentImageNumber;

}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIView *quoteView;

@property (nonatomic) NSInteger todayDay;
@property (nonatomic) NSInteger firstDayOfAppRun;
@property (nonatomic, getter = isProVersion) BOOL proVersion;
@property (nonatomic, strong) UIImage *currentImage;
@end

@implementation CardViewController

// Getters and setters

-(void)setCurrentIndex:(NSInteger)currentIndex {
    
    NSLog(@"currentIndex setter called with value %d", currentIndex);
    
    if (currentIndex == 0) {
        self.previousQuoteButton.enabled = NO;
    } else {
        self.previousQuoteButton.enabled = YES;
    }
    
    if (currentIndex == self.quotesArray.count-1) {
        self.nextQuoteButton.enabled = NO;
    } else {
        self.nextQuoteButton.enabled = YES;
    }

    
    if (currentIndex >= 0 && currentIndex < self.quotesArray.count) {
        
        QuotesClass *quote = [self.quotesArray objectAtIndex:currentIndex];
        NSInteger quoteDay = self.firstDayOfAppRun + quote.quoteId - 1; // Quote ID starts from 1
        
        if (quoteDay > self.todayDay && !self.isProVersion) {
            NSLog(@"ProFeature called with quoteDay:%d and todayDay:%d",quoteDay, self.todayDay);
            [self askToBuyProVersion];
        } else {

            // update the quote on the view
            NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:[NSDate date]];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"D-yyyy"];
            
            NSDate *quoteDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%d-%d", (quoteDay % 365), ([components year]+(quoteDay/365))]];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            
            self.quoteLabel.text = quote.quote;
            self.authorName.text = quote.author;
            self.quoteDateLabel.text = [dateFormatter stringFromDate:quoteDate];
            self.favouriteQuoteButton.selected = [DBCore isFavoriteQuote:quote.quoteId];//quote.isFavourite;
            
//            if (_currentIndex != currentIndex || !_currentIndex) {
                _currentIndex = currentIndex;
                [self pickRandomBackgrounds];
//            }
            
        }
    }
    
}

-(NSInteger)todayDay {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
}

-(NSInteger)firstDayOfAppRun {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [(NSNumber*)[defaults objectForKey:@"isFirstRun"] integerValue];
}

-(BOOL)isProVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [(NSNumber*)[defaults objectForKey:@"isProVersion"] boolValue];
}


// private functions

-(void)askToBuyProVersion {
    NSLog(@"User trying to access pro feature.");
    if (!self.isProVersion) {
        
        //Show a popup to tell user he is trying to access pro version feature and give him option to buy it.
        [[[UIAlertView alloc]initWithTitle:@"Upgrade to pro version?" message:@"Do you want to upgrade to pro version to unlock all quotes and remove ad?" delegate:self cancelButtonTitle:@"No, May be later!" otherButtonTitles:@"Yes, Upgrade now!", nil]show ];
        
    } else {
        NSLog(@"User is already running pro version. This function should not be called!!");
    }
}

-(void) pickRandomBackgrounds{
    currentImageNumber = ++currentImageNumber % IMAGE_COUNT;
    
//    NSInteger randomImages;
//    do {
//        randomImages = arc4random() % IMAGE_COUNT;
//    } while (currentImageNumber == randomImages);
//    currentImageNumber = randomImages;
    
    self.currentImage = getImageWithId(currentImageNumber);
    self.backgroundImageView.image = self.currentImage;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:self.currentImage];
}


// View Lifecycle

- (void)viewDidLoad
{
    NSLog(@"CardViewController:viewDidLoad");
    [super viewDidLoad];
    
    // Is this first run of application
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"isFirstRun"]) {
        NSLog(@"Application is running for the first time. Check point created.");

        [defaults setObject:[NSNumber numberWithInt:self.todayDay] forKey:@"isFirstRun"];
        [defaults setObject:[NSDate date] forKey:@"firstDate"];
        [defaults setObject:[NSNumber numberWithInt:0] forKey:@"isProVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self createNotification];
        
    }
//    [self createNotification];


    // setup the view (label round corner, transluscent, etc.)
    [self.quoteView.layer setCornerRadius:9.0f];
    self.quoteView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    self.previousQuoteButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self.previousQuoteButton.layer setCornerRadius:9.0f];
    self.nextQuoteButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    [self.nextQuoteButton.layer setCornerRadius:9.0f];
    
    currentImageNumber = arc4random()  % IMAGE_COUNT;
}

-(void)viewWillAppear:(BOOL)animated {
    
    // Do we have any quote in array? if yes display the current index, else load all quotes from db and display current date quote
    
    if (!self.quotesArray || self.quotesArray.count <=0) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSUInteger dayOfYear = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
        
        self.quotesArray = [DBCore getAllQuotes];
//        NSLog(@"Array %@", self.quotesArray);
        self.currentIndex = dayOfYear - self.firstDayOfAppRun;
    }
    
    if (!self.backgroundImageView.image) {
        self.currentIndex = self.currentIndex;
    }
    
    // check if we are pro, then disable ads else enable them
    if (self.isProVersion) {
        self.canDisplayBannerAds = NO;
    } else {
        self.canDisplayBannerAds = YES;
    }
}


-(void) createNotification{

	NSLog(@"createNotification");
    
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    // Extract date components into components1
    NSDateComponents *components1 = [gregorianCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    
    [components setYear:components1.year];
    [components setMonth:components1.month];
    [components setDay:components1.day+1];
    [components setHour: 8];
    [components setMinute: 0];
    [components setSecond: 0];
    [calendar setTimeZone: [NSTimeZone defaultTimeZone]];
    NSDate *dateToFire = [calendar dateFromComponents:components];
    
    
    // create the notification and then set it's parameters
	UILocalNotification *notification = [[UILocalNotification alloc] init];

    if (notification)
    {

        notification.fireDate = dateToFire;
        notification.timeZone = [NSTimeZone defaultTimeZone];
        notification.repeatInterval = NSDayCalendarUnit;

        notification.alertBody = @"Have you checked today's quote?";
        notification.alertAction = @"Show me";
        notification.applicationIconBadgeNumber = 1;
        
		// this will schedule the notification to fire
		[[UIApplication sharedApplication] scheduleLocalNotification:notification];
		
        // this will fire the notification right away
//		[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
        
    }

}


- (IBAction)backQuote:(id)sender {
    self.currentIndex--;
}


- (IBAction)nextQuote:(id)sender {
    self.currentIndex++;
}
    


- (IBAction)makeQuoteAsFavourite:(UIButton*)sender {
    
    sender.selected = !sender.selected;
    QuotesClass *quote = [self.quotesArray objectAtIndex:self.currentIndex];
    [DBCore setFavoriteTo:sender.selected ofQuoteId:quote.quoteId];
    quote.isFavourite = sender.selected;

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        self.tabBarController.selectedIndex = 3;
    }
}


- (IBAction)shareButton:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Sharing Option:" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:  @"Share on Facebook",
                            @"Share on Twitter",
                            @"Share via E-mail",
                            nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.originalContentView];
    
}

-(UIImage*) drawView:(UIView*)view inImage:(UIImage*)image andText:(NSString*)string atPoint:(CGPoint)point
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:15];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), (image.size.width - view.frame.size.width)/2 , (image.size.height - view.frame.size.height)/2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), -(image.size.width - view.frame.size.width)/2 , -(image.size.height - view.frame.size.height)/2);
    
    
    [string drawInRect:CGRectIntegral(rect) withFont:font];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                {
                    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                        
                        
                        [controller setInitialText:[NSString stringWithFormat:@"%@ \n~%@", self.quoteLabel.text, self.authorName.text]];
                        [controller addURL:[NSURL URLWithString:SHARE_URL]];
                        [controller addImage:[self drawView:self.quoteView inImage:self.currentImage andText:SHARE_URL atPoint:CGPointMake(20, 20)]];
                        [self presentViewController:controller animated:YES completion:Nil];
                    } else {
                        [[[UIAlertView alloc]initWithTitle:@"Facebook account not linked!" message:@"Connect your Facebook account in settings app." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
                    }
                }
                    break;
                case 1:
                {
                    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
                        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                        
                        [controller setInitialText: [NSString stringWithFormat:@"%@ \n~%@", self.quoteLabel.text, self.authorName.text]];
                        [controller addURL:[NSURL URLWithString:SHARE_URL]];
                        [controller addImage:[self drawView:self.quoteView inImage:self.currentImage andText:SHARE_URL atPoint:CGPointMake(20, 20)]];
                        [self presentViewController:controller animated:YES completion:Nil];
                    } else {
                        [[[UIAlertView alloc]initWithTitle:@"Twitter account not linked!" message:@"Connect your Twitter account in settings app." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
                    }
                }
                    break;
                case 2:
                {
                    
                    NSString *emailTitle = @"Quote of The Day";
                    NSString *messageBody = [NSString stringWithFormat:@"%@ \n~%@",self.quoteLabel.text, self.authorName.text ];
                    NSArray *toRecipents = [NSArray arrayWithObject:@""];
                    
                    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                    mc.mailComposeDelegate = self;
                    [mc setSubject:emailTitle];
                    [mc setMessageBody:messageBody isHTML:NO];
                    [mc setToRecipients:toRecipents];
                    NSString *mimeType = @"image/jpeg";
                    
                    UIImage* image = [self drawView:self.quoteView inImage:self.currentImage andText:SHARE_URL atPoint:CGPointMake(20, 20)];//self.currentImage;
                    NSData* data = UIImageJPEGRepresentation(image, 1.0);
                    [mc addAttachmentData:data mimeType:mimeType fileName:@"Quote.jpg"];
                    
                    [self presentViewController:mc animated:YES completion:NULL];
                    NSLog(@"Email Send");
                    
                }
                    break;
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
