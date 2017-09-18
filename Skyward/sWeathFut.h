//
//  sWeathFut.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#ifndef __Skyward__sWeathFut__
#define __Skyward__sWeathFut__

#include <iostream>

struct sWeathFut
{
    // Данные для прогноза на будущей день
    
    char Date[16];      // <date>2013-04-11</date>
    
    int nTempMaxC;      // <tempMaxC>2</tempMaxC>
    int nTempMinC;      // <tempMinC>1</tempMinC>
    
    //<tempMaxF>36</tempMaxF>
    //<tempMinF>34</tempMinF>
    
    int nWindSpeedKmph; // <windspeedKmph>15</windspeedKmph>
    
    // <windspeedMiles>9</windspeedMiles>
    
    char WindDir[8];    // <winddirection>SSE</winddirection>
    
    // <winddir16Point>SSE</winddir16Point>
    
    int nWindDegree;    // <winddirDegree>152</winddirDegree>
    
    int nWeatherCode;   // <weatherCode>266</weatherCode>
    
    //<weatherIconUrl>
    //<![CDATA[http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0017_cloudy_with_light_rain.png]]>
    //</weatherIconUrl>
    
    char WeatherDesc[32]; // <weatherDesc>
                          // <![CDATA[Light drizzle]]>
                          // </weatherDesc>
    
    // <precipMM>3.0</precipMM>
    
    sWeathFut();
};

#endif /* defined(__Skyward__sWeathFut__) */
