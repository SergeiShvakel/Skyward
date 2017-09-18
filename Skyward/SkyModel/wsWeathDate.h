//
//  wsWeathDate.h
//  Skyward
//
//  Created by Сергей Швакель on 29.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wsWeathDate : NSObject
{
    // Данные для погодных условий на дату
    NSString *CurrentCity;      // Текущий город
    NSString *ForDate;          // <date>2013-04-17</date>
    
    NSInteger nTempMaxC;        // <tempMaxC>7</tempMaxC>
    NSInteger nTempMaxF;        // <tempMaxF>45</tempMaxF>
    NSInteger nTempMinC;        // <tempMinC>7</tempMinC>
    NSInteger nTempMinF;        // <tempMinF>45</tempMinF>
    
    NSInteger nWindSpeedMiles;  // <windspeedMiles>7</windspeedMiles>
    NSInteger nWindSpeedKmph;   // <windspeedKmph>7</windspeedKmph>
    NSString *sWindDirection;
    NSString *sWindDir16Point;  // <winddir16Point>SSE</winddir16Point>
    NSInteger nWindDirDegree;   // <winddirDegree>160</winddirDegree>
    
    NSInteger nWeatherCode;     // <weatherCode>353</weatherCode>
    
    //<weatherIconUrl>
    //<![CDATA[http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0025_light_rain_showers_night.png]
    //</weatherIconUrl>
    NSString *weatherIconUrl;
    
    // <weatherDesc>
    // <![CDATA[Light rain shower]]>
    // </weatherDesc>
    NSString *WeatherDesc;
    
    double fPrecipMM;  //<precipMM>0.5</precipMM>
}

@property (strong, nonatomic) NSString *CurrentCity;
@property (strong, nonatomic) NSString *ForDate;

@property (nonatomic) NSInteger nTempMaxC;
@property (nonatomic) NSInteger nTempMaxF;
@property (nonatomic) NSInteger nTempMinC;
@property (nonatomic) NSInteger nTempMinF;

@property (nonatomic) NSInteger nWindSpeedMiles;
@property (nonatomic) NSInteger nWindSpeedKmph;

@property (strong, nonatomic) NSString *sWindDirection;
@property (strong, nonatomic) NSString *sWindDir16Point;
@property (nonatomic) NSInteger nWindDirDegree;

@property (nonatomic) NSInteger nWeatherCode;

@property (strong, nonatomic) NSString *weatherIconUrl;
@property (strong, nonatomic) NSString *WeatherDesc;

@property (nonatomic) double fPrecipMM;

- (id)init;
- (void)clear;


@end
