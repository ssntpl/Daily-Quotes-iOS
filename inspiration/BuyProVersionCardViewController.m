//
//  BuyProVersionCardViewController.m
//  facebookSharing
//
//  Created by Sword Software on 25/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import "BuyProVersionCardViewController.h"
#import "MAConfirmButton.h"
#import "IAP.h"

@interface BuyProVersionCardViewController () {
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
    MAConfirmButton *buyButton;
}
@property (weak, nonatomic) IBOutlet UILabel *proVersionDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (strong, nonatomic) SKProductsRequest *request;
@property (strong, nonatomic) SKProduct *product;
@property (strong, nonatomic) NSString *productID;

@end

@implementation BuyProVersionCardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(BOOL)isProVersion {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [(NSNumber*)[defaults objectForKey:@"isProVersion"] boolValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSLog(@"BuyProVersionCardViewController:viewDidLoad");
    
    self.productID = @"com.ssntpl.ios.inspiration.proversion";

    if ([SKPaymentQueue canMakePayments])
    {
        NSLog(@"READY TO SEND PAYMENT REQUEST");
//        self.request = [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject:self.productID]];
//        self.request.delegate = self;
//        [self.request start];
        [self requestProducts];
    }
    else {
        NSLog (@"Please enable In App Purchase in Settings");
        [[[UIAlertView alloc] initWithTitle:@"In-App purchase not available!" message:@"Please enable In-App Purchase in Settings" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]show];
    }
    
    
    self.proVersionDescriptionLabel.hidden = YES;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)",version,build];
//    [self resetBuyButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    NSLog(@"into productPurchased after notification");
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            
            // We have only one product in our _products array, still we want to enumerate so that if in future we add more products we can modify this easily
            [buyButton disableWithTitle:@"Purchased!"];
            
            
            *stop = YES;
        }
    }];
    
}

- (void)requestProducts {
    _products = nil;

    [[IAP sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
            self.product = [products lastObject];
            [self resetBuyButton];
        }

    }];
}

- (IBAction)launchWebsite:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.ssntpl.com/daily-quotes-app/"]];
    
}

- (IBAction)launchCustomerEmail:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:support@ssntpl.com"]];
}

- (IBAction)restoreIAP:(UIBarButtonItem *)sender {
    [[IAP sharedInstance] restoreCompletedTransactions];
}

- (void)resetBuyButton {
    [buyButton removeFromSuperview];
    
    NSNumberFormatter *priceFormatter = [[NSNumberFormatter alloc] init];
    [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [priceFormatter setLocale:self.product.priceLocale];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    buyButton = [MAConfirmButton buttonWithTitle:[NSString stringWithFormat:@"Upgrade to pro version for only %@",[priceFormatter stringFromNumber:self.product.price]] confirm:@"Confirm"];
    buyButton.toggleAnimation = MAConfirmButtonToggleAnimationCenter;
    [buyButton addTarget:self action:@selector(buyProVersion:) forControlEvents:UIControlEventTouchUpInside];
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        // code for landscape orientation
        [buyButton setAnchor:CGPointMake(screenHeight - (screenHeight - buyButton.frame.size.width)/2, screenWidth - 90)];
    } else {
        [buyButton setAnchor:CGPointMake(screenWidth - (screenWidth - buyButton.frame.size.width)/2, screenHeight - 120)];
    }
    
    [self.view addSubview:buyButton];
    self.proVersionDescriptionLabel.hidden = NO;
    
    if ([self isProVersion]) {
        [buyButton disableWithTitle:@"Purchased!"];
    }
}

- (void)buyProVersion:(id)sender {
    if (self.product) {
//        [buyButton disableWithTitle:@"Purchasing.."];
        
        [[IAP sharedInstance] buyProduct:self.product];
    } else {
        NSLog(@"Product not available!");
        [buyButton disableWithTitle:@"Oops! Product not available."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self resetBuyButton];
        });
    }
    
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
        NSLog(@"Ratoted to landscape! with screen widht:%f and height:%f ", screenWidth, screenHeight);
        [buyButton setAnchor:CGPointMake(screenHeight - (screenHeight - buyButton.frame.size.width)/2, screenWidth - 90)];
    }
    else
    {
        NSLog(@"Ratoted to portrait! with screen widht:%f and height:%f ", screenWidth, screenHeight);
        
        [buyButton setAnchor:CGPointMake(screenWidth - (screenWidth - buyButton.frame.size.width)/2, screenHeight - 120)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
