//
//  wsWeathDate.m
//  Skyward
//
//  Created by Сергей Швакель on 29.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "wsWeathDate.h"

@implementation wsWeathDate
{
    
}
@synthesize CurrentCity;
@synthesize ForDate;

@synthesize nTempMaxC;
@synthesize nTempMaxF;
@synthesize nTempMinC;
@synthesize nTempMinF;

@synthesize nWindSpeedMiles;
@synthesize nWindSpeedKmph;

@synthesize sWindDirection;
@synthesize sWindDir16Point;
@synthesize nWindDirDegree;

@synthesize nWeatherCode;

@synthesize weatherIconUrl;
@synthesize WeatherDesc;

@synthesize fPrecipMM;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        CurrentCity = nil;
        ForDate = nil;
        
        nTempMaxC = 0;
        nTempMaxF = 0;
        nTempMinC = 0;
        nTempMinF = 0;
        
        nWindSpeedMiles = 0;
        nWindSpeedKmph = 0;
        
        sWindDirection = nil;
        sWindDir16Point = nil;
        nWindDirDegree = 0;
        
        nWeatherCode = 0;
        
        weatherIconUrl = nil;
        WeatherDesc = nil;
        
        fPrecipMM = 0.0;
    }
    return self;
}

- (void)clear
{
    CurrentCity = nil;
    ForDate = nil;
    
    nTempMaxC = 0;
    nTempMaxF = 0;
    nTempMinC = 0;
    nTempMinF = 0;
    
    nWindSpeedMiles = 0;
    nWindSpeedKmph = 0;
    
    sWindDirection = nil;
    sWindDir16Point = nil;
    nWindDirDegree = 0;
    
    nWeatherCode = 0;
    
    weatherIconUrl = nil;
    WeatherDesc = nil;
    
    fPrecipMM = 0.0;
}
@end
