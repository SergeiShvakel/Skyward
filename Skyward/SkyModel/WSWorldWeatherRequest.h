//
//  WSWorldWeatherRequest.h
//  Skyward
//
//  Created by Сергей Швакель on 15.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSIWeatherRequest.h"
#import "WSIWeatherRequestDelegate.h"
#import "wsWeath.h"

#import "XPathQuery.h"


@interface WSWorldWeatherRequest : NSObject <WSIWeatherRequest,  NSURLConnectionDelegate>
{
    NSURLConnection *m_URLConnection;
    NSMutableData *responseData;
    NSURL *theURL; // http://api.worldweatheronline.com/free/v1/weather.ashx?q=Minsk&format=xml&num_of_days=4&key=b7kcv89dqdk597kr2q3rf4sr
    
    SWREQUESTTYPE m_reqType;
    
    bool m_bLoading;
}

@property (weak, nonatomic) id<WSIWeatherRequestDelegate> delegate;

- (id) initWith:(id<WSIWeatherRequestDelegate>)delegate;

/*
    Метод запускает процесс запроса погоды в асинхронном режиме для местоположения и количества дней
    для запроса погоды
*/
- (void)MakeForecastRequest:(NSString*) location forDay:(NSInteger) forDay;

/*
    Метод выполняет запрос на поиск текущего города.
*/
- (void) MakeFindLocationRequest:(NSString*) location;

/*
    Возвращает YES, если разбор был выполнен успешно.
*/
- (bool) GetCurrentWeather: (wsWeath*) weather;
- (bool) GetWeatherForDay: (NSInteger) index toItem: (wsWeathDate*)item;

/*
    Получение текущих результатов запроса поиска местоположения.
        Данные помещаются в вектор arrSearch структур sCity.
    Возвращает YES, если разбор был выполнен успешно.
*/
- (bool) getSearchLocations:(NSMutableArray**) arrSearch Error: (NSError**)error;

@end
