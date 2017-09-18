//
//  WSIWeatherRequestDelegate.h
//  Skyward
//
//  Created by Сергей Швакель on 15.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSIWeatherRequestDelegate <NSObject>

/*
    Оповещение об окончании загрузки данных.
*/
- (void) MakeRequestsFinished: (id<WSIWeatherRequest>) source RequestType: (NSInteger)reqType WithError: (NSError*) error;
/*
    Получение размера возвращаемых данных.
*/
- (void) RequestExpectedLength: (id<WSIWeatherRequest>) source  ExpectedLength: (long) expLength;
/*
    Размер в полученных данных в байтах.
*/
- (void) RequestDidRecieveBytes: (id<WSIWeatherRequest>) source  RecieveBytes: (long) recieveBytes;

@end
