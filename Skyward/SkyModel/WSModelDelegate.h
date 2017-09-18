//
//  WSModelDelegate.h
//  Skyward
//
//  Created by Сергей Швакель on 15.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WSModel;

@protocol WSModelDelegate <NSObject>

@optional
- (void) LoadingRequestDidFinish:(WSModel*)model RequestType:(NSInteger)reqType WithError:(NSError*) error;
- (void) LoadingInitialDataDidFinish:(WSModel*)model;

- (void) LoadingRequestExpectLength: (WSModel*)model  ExpectLength:(long)ExpectLength;
- (void) LoadingRequestGetBytes: (WSModel*)model  GetBytes:(long)getBytes;

@end
