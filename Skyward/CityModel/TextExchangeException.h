//
//  TextExchangeException.h
//  Skyward
//
//  Created by Сергей Швакель on 09.09.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextExchangeException : NSException

+ (id) exceptionWithCode: (NSInteger) code;

@end
