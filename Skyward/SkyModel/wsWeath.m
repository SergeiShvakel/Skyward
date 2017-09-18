//
//  wsWeath.m
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "wsWeath.h"

@implementation wsWeath
{
}

@synthesize IDLocation;

@synthesize CurrentCity;
@synthesize CurrentTime;
@synthesize nTempC;

@synthesize weatherIconUrl;
@synthesize WeatherDesc;

@synthesize nHumidity;
@synthesize nWindSpeedKmph;
@synthesize nWindDir;
@synthesize WindDirPoint;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        IDLocation = 0;
        
        CurrentCity = nil;
        CurrentTime = nil;
        
        nTempC = 0;
        nTempF = 0;
        nWeatherCode = 0;
        weatherIconUrl = nil;
        
        WeatherDesc = nil;
        nWindSpeedKmph = 0;
        
        nWindDir = 0;
        WindDirPoint = nil;
        
        nHumidity = 0;
    }
    return self;
}

- (void)clear
{
    IDLocation = 0;
    
    CurrentCity = nil;
    CurrentTime = nil;
    
    nTempC = 0;
    nTempF = 0;
    nWeatherCode = 0;
    weatherIconUrl = nil;
    
    WeatherDesc = nil;
    nWindSpeedKmph = 0;
    
    nWindDir = 0;
    WindDirPoint = nil;
    
    nHumidity = 0;
}

@end
