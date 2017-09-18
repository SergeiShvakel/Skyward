//
//  wsWeath.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface wsWeath : NSObject
{
    NSUInteger IDLocation;     // Номер местоположения с 1
    // Данные для текущей погоды
    NSString *CurrentCity;      // Текущий город
    NSString *CurrentTime;      // <observation_time>07:22 PM</observation_time>

    NSInteger nTempC;           // <temp_C>7</temp_C>
    NSInteger nTempF;           // <temp_F>45</temp_F>
    NSInteger nWeatherCode;     // <weatherCode>353</weatherCode>

    //<weatherIconUrl>
    //<![CDATA[http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0025_light_rain_showers_night.png]
    //</weatherIconUrl>
    NSString *weatherIconUrl;

    NSString *WeatherDesc;      // <weatherDesc>
    // <![CDATA[Light rain shower]]>
    // </weatherDesc>
    NSInteger nWindSpeedKmph;   // <windspeedKmph>7</windspeedKmph>

    // <windspeedMiles>4</windspeedMiles>
    NSInteger nWindDir;         // <winddirDegree>160</winddirDegree>
    NSString *WindDirPoint;     // <winddir16Point>SSE</winddir16Point>

    //<precipMM>0.5</precipMM>
    NSInteger nHumidity;        // <humidity>66</humidity>

    //<visibility>10</visibility>
    //<pressure>1013</pressure>
    //<cloudcover>100</cloudcover>
}

@property (nonatomic) NSUInteger IDLocation;

@property (strong, nonatomic) NSString *CurrentCity;
@property (strong, nonatomic) NSString *CurrentTime;
@property (nonatomic) NSInteger nTempC;

@property (strong, nonatomic) NSString *weatherIconUrl;
@property (strong, nonatomic) NSString *WeatherDesc;

@property (nonatomic) NSInteger nHumidity;
@property (nonatomic) NSInteger nWindSpeedKmph;
@property (nonatomic) NSInteger nWindDir;
@property (strong, nonatomic) NSString *WindDirPoint;


- (id)init;
- (void)clear;

@end
