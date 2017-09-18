//
//  sWeath.cpp
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#include "sWeath.h"

sWeath::sWeath()
{
    CurrentTime[0] = 0;
    
    nTempC = 0;
    nTempF = 0;
    nWeatherCode = 0;
    
    WeatherDesc[0] = 0;
    nWindSpeedKmph = 0;
    
    nWindDir = 0;
    WindDirPoint[0] = 0;
    
    nHumidity = 0;
}