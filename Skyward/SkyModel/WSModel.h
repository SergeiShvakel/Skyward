//
//  WSModel.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSIWeatherRequest.h"
#import "WSIWeatherRequestDelegate.h"
#import "WSModelDelegate.h"
#import "wsWeath.h"
#import "wsWeathDate.h"
#import "sCity.h"

@protocol WSModelDelegate;
@protocol WSIWeatherRequestDelegate;

@interface WSModel : NSObject <WSIWeatherRequestDelegate>
{
    id <WSIWeatherRequest> m_WeatherSource;

    wsWeath *m_CurrWeather;             // Текущая погода
    NSArray *m_WeatherForDate;          // Погода на N дней
    
    NSInteger m_DaysCount;              // Получить погоду на N дней
    
    NSArray *m_FaivoritCities;          // массив сохраненных городов sCity
    NSString *m_sFaivoritFileName;      // Имя файла сохранения списка городов
    
    NSUInteger m_lastIDLocation;        // Номер последнего (текущего) просматриваемого города с 1
    
    NSMutableArray *m_LastSearchLocation; //вектор структур sCity
}

@property (weak, nonatomic) id <WSModelDelegate> delegate;

@property (readonly) wsWeath *m_CurrWeather;
@property (readonly) NSArray *m_WeatherForDate;
@property (readonly) NSMutableArray *m_LastSearchLocation;

@property (readonly) NSUInteger m_lastIDLocation;

- (id) init;
- (void) dealloc;

- (void) loadFaivoritLocations;
- (void) saveFaivoritLocations;

- (NSUInteger) getCountCity;
- (sCity*) getCity: (NSUInteger) index;

- (bool) addFaivoriteLocations:(sCity*)location;

// Методы загрузки данных
/*
    Метод проверяет: необходимо ли обновление данных по погоде для данного местоположения.
*/
- (bool) isNeedUpdateWeathForecast:(NSUInteger)IDLocation;
- (bool) loadWeathForecast:(NSUInteger)IDLocation;

- (void) LoadData;
- (void) loadLocations:(NSString*) location;


@end
