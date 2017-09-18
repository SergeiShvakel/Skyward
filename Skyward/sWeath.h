//
//  sWeath.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#ifndef __Skyward__sWeath__
#define __Skyward__sWeath__

#include <iostream>

struct sWeath
{
    // Данные для текущей погоды
    char CurrentTime[16];   // <observation_time>07:22 PM</observation_time>
    
    int nTempC;             // <temp_C>7</temp_C>
    int nTempF;             // <temp_F>45</temp_F>
    int nWeatherCode;       // <weatherCode>353</weatherCode>
    
    //<weatherIconUrl>
    //<![CDATA[http://www.worldweatheronline.com/images/wsymbols01_png_64/wsymbol_0025_light_rain_showers_night.png]
    //</weatherIconUrl>
    
    char WeatherDesc[32];   // <weatherDesc>
                            // <![CDATA[Light rain shower]]>
                            // </weatherDesc>
    int nWindSpeedKmph;     // <windspeedKmph>7</windspeedKmph>
    
                            // <windspeedMiles>4</windspeedMiles>
    int nWindDir;           // <winddirDegree>160</winddirDegree>
    char WindDirPoint[8];   // <winddir16Point>SSE</winddir16Point>
    
    //<precipMM>0.5</precipMM>
    int nHumidity;          // <humidity>66</humidity>
    
    //<visibility>10</visibility>
    //<pressure>1013</pressure>
    //<cloudcover>100</cloudcover>
    
    sWeath();
    
};

#endif /* defined(__Skyward__sWeath__) */
