//
//  IAP.m
//  inspiration
//
//  Created by Sambhav on 4/4/14.
//  Copyright (c) 2014 ssntpl.com. All rights reserved.
//

#import "IAP.h"

@implementation IAP

+ (IAP *)sharedInstance {
    static dispatch_once_t once;
    static IAP * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithArray:[NSArray arrayWithObjects:@"com.ssntpl.ios.inspiration.proversion", nil]];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
