//
//  TextExchangeException.m
//  Skyward
//
//  Created by Сергей Швакель on 09.09.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "TextExchangeException.h"

@implementation TextExchangeException

+ (id) exceptionWithCode: (NSInteger) code
{
    NSDictionary *dopInfo = nil;
    NSNumber *num_code = nil;
    num_code = [NSNumber numberWithInteger:code];
    
    dopInfo = [NSDictionary dictionaryWithObject:num_code forKey:@"code"];
    
    TextExchangeException *retExcept = nil;
    retExcept = [[TextExchangeException alloc] initWithName:@"exit code" reason:@"Exit Code" userInfo:dopInfo];
    
    return retExcept;
}

@end
