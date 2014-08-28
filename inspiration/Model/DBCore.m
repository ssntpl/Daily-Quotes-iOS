//
//  DBCore.m
//  facebookSharing
//
//  Created by Sword Software on 28/03/14.
//  Copyright (c) 2014 Sword Software. All rights reserved.
//

#import "DBCore.h"

@implementation DBCore

+(NSString*) dbPath {
    // This is used to copy database from app bundle to app documents.
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
    
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];

	if (![fileManager fileExistsAtPath:writableDBPath])
	{
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
        [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        NSLog(@"Database not Found, copied at new location.");
	}
    
    return writableDBPath;
}

+ (void) insertInSettingsName:(NSString*)name Value:(NSString*)value {
    sqlite3 *database;
    
    if(sqlite3_open([[[self class] dbPath] UTF8String], &database)==SQLITE_OK)
    {
        NSString *statement;
        sqlite3_stmt *compliedstatement;
        
        statement = [[NSString alloc] initWithFormat:@"delete from `settings` where `name` = '%@'", name]; //[NSString stringWithFormat: @"delete from settings"];// where 'name' = '%@'", name];
        const char *sqlStatement = [statement UTF8String];
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compliedstatement, NULL) == SQLITE_OK)
        {
            if (SQLITE_DONE != sqlite3_step(compliedstatement)) {
                NSAssert1(0, @"Error while inserting data in DB. '%s'", sqlite3_errmsg(database));
                NSLog(@"Failed to insert data in DB.");
            } else {
                //NSLog(@"Successfully inserted data in DB.");
            }
        }
        
        statement = [[NSString alloc] initWithFormat:@"insert into `settings` ('name', 'value') values('%@','%@')", name, value];
        const char *sqlStatement2 = [statement UTF8String];
        if (sqlite3_prepare_v2(database, sqlStatement2, -1, &compliedstatement, NULL) == SQLITE_OK)
        {
            if (SQLITE_DONE != sqlite3_step(compliedstatement)) {
                NSAssert1(0, @"Error while inserting data in DB. '%s'", sqlite3_errmsg(database));
                NSLog(@"Failed to insert data in DB.");
            } else {
                //NSLog(@"Successfully inserted data in DB.");
            }
        }
        sqlite3_finalize(compliedstatement);
    }
    sqlite3_close(database);
}

+ (NSString*) getSetting:(NSString*)name {
    
    NSString *setting;
    sqlite3 *database;
    if(sqlite3_open([[[self class] dbPath] UTF8String], &database)==SQLITE_OK)
    {
        NSString *statement;
        sqlite3_stmt *compliedstatement;
        
        statement = [[NSString alloc] initWithFormat:@"SELECT `value` FROM `settings` WHERE name = '%@'", name];
        const char *sqlStatement = [statement UTF8String];
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compliedstatement, NULL) == SQLITE_OK) {
            if (sqlite3_step(compliedstatement) == SQLITE_ROW)
                setting = [NSString stringWithUTF8String:((char *)sqlite3_column_text(compliedstatement, 0))?(char *)sqlite3_column_text(compliedstatement, 0):""];
            else
                setting = @"";
        }
        sqlite3_finalize(compliedstatement);
    }
    sqlite3_close(database);
    return setting;
}

+(NSArray*)getAllQuotes {
    sqlite3	*database;
    NSMutableArray *quoteList = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dbPath] UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        NSString *selectSQL = [NSString stringWithFormat:@"select * from quotes"];
//        NSLog(@"getAllQuotes. Query: %@",selectSQL);
        const char *select_smt = [selectSQL UTF8String];
        //sqlite3_prepare_v2(database, select_smt,-1, &statement, NULL);
        
        if (sqlite3_prepare_v2(database, select_smt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                QuotesClass *obj = [[QuotesClass alloc]init];
                obj.quoteId = sqlite3_column_int(statement, 0);
                obj.quote = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                obj.author = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                obj.isFavourite = sqlite3_column_int(statement, 3);
                obj.category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                [quoteList addObject:obj];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return [quoteList copy];
}

+(NSArray*)getFavoriteQuotes {
    sqlite3	*database;
    NSMutableArray *quoteList = [[NSMutableArray alloc] init];
    
    if (sqlite3_open([[self dbPath] UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        NSString *selectSQL = [NSString stringWithFormat:@"select * from quotes where isFavourite=1"];
        //        NSLog(@"getAllQuotes. Query: %@",selectSQL);
        const char *select_smt = [selectSQL UTF8String];
        //sqlite3_prepare_v2(database, select_smt,-1, &statement, NULL);
        
        if (sqlite3_prepare_v2(database, select_smt, -1, &statement, NULL) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                QuotesClass *obj = [[QuotesClass alloc]init];
                obj.quoteId = sqlite3_column_int(statement, 0);
                obj.quote = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                obj.author = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                obj.isFavourite = sqlite3_column_int(statement, 3);
                obj.category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                [quoteList addObject:obj];
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return [quoteList copy];
}

+(BOOL)isFavoriteQuote:(NSInteger)quoteID {
    sqlite3	*database;
    BOOL isFav=NO;
    
    if (sqlite3_open([[self dbPath] UTF8String], &database) == SQLITE_OK)
    {
        sqlite3_stmt *statement;
        
        NSString *selectSQL = [NSString stringWithFormat:@"select isFavourite from quotes where QuoteID=%d",quoteID];
        //        NSLog(@"getAllQuotes. Query: %@",selectSQL);
        const char *select_smt = [selectSQL UTF8String];
        //sqlite3_prepare_v2(database, select_smt,-1, &statement, NULL);
        
        if (sqlite3_prepare_v2(database, select_smt, -1, &statement, NULL) == SQLITE_OK) {
            
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                isFav = sqlite3_column_int(statement, 0);
            }
            sqlite3_finalize(statement);
        }
        sqlite3_close(database);
    }
    return isFav;
}

+(void)setFavoriteTo:(BOOL)fav ofQuoteId:(NSInteger)quoteID {
    sqlite3 *database;
    if(sqlite3_open([[[self class] dbPath] UTF8String], &database)==SQLITE_OK)
    {
        NSString *statement;
        sqlite3_stmt *compliedstatement;
        
        statement = [NSString stringWithFormat:@"UPDATE quotes SET isFavourite=%d WHERE QuoteID=%d", fav, quoteID];
        NSLog(@"Query: %@", statement);
        const char *sqlStatement = [statement UTF8String];
        
        if (sqlite3_prepare_v2(database, sqlStatement, -1, &compliedstatement, NULL) == SQLITE_OK) {
            char* errmsg;
            sqlite3_exec(database, "COMMIT", NULL, NULL, &errmsg);
            if(SQLITE_DONE != sqlite3_step(compliedstatement)){
                NSLog(@"Error while updating. %s", sqlite3_errmsg(database));
            }
        } else {
            NSLog(@"Failed to update quotes!");
        }
        sqlite3_finalize(compliedstatement);
    }
    sqlite3_close(database);
}

@end
