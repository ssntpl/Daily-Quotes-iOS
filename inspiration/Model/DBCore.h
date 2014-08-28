//
//  DBCore.h
//  facebookSharing
//
//  Created by Sword Software on 28/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "QuotesClass.h"


#define DB_NAME (@"QuoteDatabase.sqlite")

@interface DBCore : NSObject

+(NSArray*)getAllQuotes;
+(NSArray*)getFavoriteQuotes;
+(BOOL)isFavoriteQuote:(NSInteger)quoteID;

+(void)setFavoriteTo:(BOOL)fav ofQuoteId:(NSInteger)quoteID;

@end
