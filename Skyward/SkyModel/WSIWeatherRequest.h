//
//  WSIWeatherRequest.h
//  Skyward
//
//  Created by Сергей Швакель on 15.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "wsWeath.h"
#import "wsWeathDate.h"

typedef
enum _swRequestType {
    
    SW_FORECAST_REQ = 1,    // запрос погоды
    SW_SEARCH_REQ   = 2     // запрос текущего местоположения
    
} SWREQUESTTYPE;

@protocol WSIWeatherRequest <NSObject>

@optional
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
    Методы получения данных по запросу
*/
- (bool) GetCurrentWeather:(wsWeath*) weather;
- (bool) GetWeatherForDay:(NSInteger) index toItem:(wsWeathDate*) item;

/*
    Получение текущих результатов запроса поиска местоположения.
*/
- (bool) getSearchLocations:(NSMutableArray**) arrSearch Error: (NSError**)error;

@end
