//
//  QuotesTableViewController.m
//  facebookSharing
//
//  Created by Sword Software on 10/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import "QuotesTableViewController.h"
#import "QuotesClass.h"
#import "CardViewController.h"

#define IMAGE_COUNT 36

#define getRandomImage [UIImage imageNamed:[NSString stringWithFormat:@"bg%d.jpg", (arc4random() % IMAGE_COUNT)]]

@interface QuotesTableViewController (){

    NSInteger selectedRow;

}
@property (nonatomic, strong) NSArray *quoteData;


@end

@implementation QuotesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(NSArray *)quoteData{
    
    if (_quoteData == nil) {
        if ([@"Starred" isEqualToString:self.title]) {
            _quoteData = [DBCore getFavoriteQuotes];
        } else {
            _quoteData = [DBCore getAllQuotes];
        }
        
    }
    return _quoteData;
}


-(BOOL)isProVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [(NSNumber*)[defaults objectForKey:@"isProVersion"] boolValue];
}

-(void)askToBuyProVersion {
    NSLog(@"User trying to access pro feature.");
    if (!self.isProVersion) {
        
        //Show a popup to tell user he is trying to access pro version feature and give him option to buy it.
        [[[UIAlertView alloc]initWithTitle:@"Upgrade to pro version?" message:@"Do you want to upgrade to pro version to unlock all quotes and remove ad?" delegate:self cancelButtonTitle:@"No, May be later!" otherButtonTitles:@"Yes, Upgrade now!", nil]show ];
        
    } else {
        NSLog(@"User is already running pro version. This function should not be called!!");
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1) {
        self.tabBarController.selectedIndex = 3;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:getRandomImage];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:getRandomImage];
    
    
    if ([@"Starred" isEqualToString:self.title]) {
        self.quoteData = nil;
        [self.tableView reloadData];
    }
    
    // check if we are pro, then disable ads else enable them
    if (self.isProVersion) {
        self.canDisplayBannerAds = NO;
    } else {
        self.canDisplayBannerAds = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.quoteData count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
    }
    cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    QuotesClass *obj = [self.quoteData objectAtIndex:indexPath.row];
    cell.textLabel.text = obj.quote;
    cell.detailTextLabel.text = obj.author;
//    cell.detailTextLabel.text = dateOnLabel;

    
    return cell;


}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row at index: %d", indexPath.row);
    selectedRow = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSInteger todayDay = [gregorian ordinalityOfUnit:NSDayCalendarUnit inUnit:NSYearCalendarUnit forDate:[NSDate date]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger firstDayOfAppRun = [(NSNumber*)[defaults objectForKey:@"isFirstRun"] integerValue];
    QuotesClass *quote = [self.quoteData objectAtIndex:indexPath.row];
    NSInteger quoteDay = firstDayOfAppRun + quote.quoteId - 1; // Quote ID starts from 1
    
    
    if (quoteDay > todayDay && !self.isProVersion) {
        [self askToBuyProVersion];
    }
    else {
        [self performSegueWithIdentifier: @"tableQuotesSegue" sender: self];
    }

}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"tableQuotesSegue"]) {
        CardViewController *destination = [segue destinationViewController];
        destination.quotesArray = self.quoteData;
        destination.currentIndex = selectedRow;
        destination.interstitialPresentationPolicy = ADInterstitialPresentationPolicyAutomatic;
    }
}


@end