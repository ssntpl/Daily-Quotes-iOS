//
//  ObjectClass.h
//  facebookSharing
//
//  Created by Sword Software on 10/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuotesClass : NSObject
@property (strong, nonatomic) NSString *sequence;
@property (strong, nonatomic) NSString *quote;
@property (strong, nonatomic) NSString *author;
@property (nonatomic) BOOL isFavourite;
@property (strong, nonatomic) NSString *category;
@property (nonatomic) NSInteger quoteId;
@end
