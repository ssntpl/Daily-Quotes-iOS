//
//  CardViewController.h
//  facebookSharing
//
//  Created by Sword Software on 03/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <iAd/iAd.h>
#import <MessageUI/MessageUI.h>
#import <QuartzCore/QuartzCore.h>

@interface CardViewController : UIViewController < MFMailComposeViewControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate>{

}

@property (weak, nonatomic) IBOutlet UIButton *previousQuoteButton;
@property (weak, nonatomic) IBOutlet UIButton *nextQuoteButton;
@property (weak, nonatomic) IBOutlet UIButton *favouriteQuoteButton;


@property (weak, nonatomic) IBOutlet UILabel *quoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet UILabel *quoteDateLabel;

@property (strong, nonatomic) NSArray *quotesArray;
@property (nonatomic) NSInteger currentIndex;

@end
