//
//  WSWorldWeatherRequest.m
//  Skyward
//
//  Created by Сергей Швакель on 15.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSWorldWeatherRequest.h"
#import "SBJson4Parser.h"

#import "sCity.h"

@implementation WSWorldWeatherRequest
{
}

@synthesize delegate = _delegate;

- (id) initWith:(id<WSIWeatherRequestDelegate>)delegate;
{
    self = [super init];
    if (self != nil)
    {
        theURL = nil;
        
        [self setDelegate: delegate];
        responseData = [[NSMutableData alloc] initWithCapacity:0];
        
        m_bLoading = NO;
        
        m_reqType = 0;
    }
    return self;
}

-(void)ClearData
{
    responseData = [[NSMutableData alloc] initWithCapacity:0];
}

- (void) dealloc
{
    [self setDelegate:nil];
}

- (NSString*)fetchContent: (NSArray*)nodes
{
    NSString *result = @"";
    for (NSDictionary *node in nodes)
    {
        for (id key in node)
        {
            if ( [key isEqualToString: @"nodeContent"] ) result = [node objectForKey:key];
        }
    }
    return result;
}

- (void)MakeForecastRequest:(NSString*)location forDay: (NSInteger) forDay;
{
    [self ClearData];
    
    m_reqType = SW_FORECAST_REQ;
    m_bLoading = YES;
    
    // OldFormat @"http://api.worldweatheronline.com/free/v1/weather.ashx?q=%@&format=xml&num_of_days=%ld&key=b7kcv89dqdk597kr2q3rf4sr
    //http://api.worldweatheronline.com/premium/v1/weather.ashx?key=ebbb0279fb334b4ab03200237170609&q=Minsk,Belarus&format=json&num_of_days=1
    
    NSString *url = [NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/weather.ashx?key=ebbb0279fb334b4ab03200237170609&q=%@&format=xml&num_of_days=%ld", location, (long)forDay];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUnicodeStringEncoding];
    
    theURL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    
    NSURLConnection *connect = nil;
    connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    m_URLConnection = connect;
}

/*
    Метод выполняет запрос на поиск текущего города
*/
- (void) MakeFindLocationRequest: (NSString*) location
{
    [self ClearData];
    
    m_reqType = SW_SEARCH_REQ;
    m_bLoading = YES;
    
    // Old format @"http://api.worldweatheronline.com/free/v1/search.ashx?q=%@&format=json&key=b7kcv89dqdk597kr2q3rf4sr"
    //
    
    NSString *url = [NSString stringWithFormat:@"http://api.worldweatheronline.com/premium/v1/search.ashx?key=ebbb0279fb334b4ab03200237170609&q=%@&format=json", location];
    url = [url stringByAddingPercentEscapesUsingEncoding: NSUnicodeStringEncoding];
    
    theURL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:theURL];
    
    NSURLConnection *connect = nil;
    connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    m_URLConnection = connect;
}

- (bool) GetCurrentWeather: (wsWeath*) weather
{
    if (m_bLoading == YES) return !m_bLoading;
    
    NSString *xpathQueryString = nil;
    NSArray *nodes = nil;
    
    NSString *log = [NSString stringWithFormat:@"%s", (char*)[responseData mutableBytes]];
    NSLog(@"%@", log);
    
    // Город
    xpathQueryString = @"/child::data/child::request/child::query";
    nodes = PerformXMLXPathQuery(responseData, xpathQueryString);
    if (nodes == nil)
        return NO;
    weather.CurrentCity = [self fetchContent:nodes];
    
    // Текущие погодные условия
    //xpathQueryString = @"/data/current_condition/child::element(*)";
    xpathQueryString = @"/child::data/child::current_condition[position()=1]";
    nodes = PerformXMLXPathQuery(responseData, xpathQueryString);
    
    for (NSDictionary *node in nodes)
    {
        NSString *nodeName = @"";
        for (id key in node)
        {
            if ( [key isEqualToString: @"nodeName"] ) nodeName = [node objectForKey:key];
            else
            if ([key isEqualToString: @"nodeChildArray"])
            {
                NSArray *nodeChild = (NSArray*)[node objectForKey:key];
                for (NSDictionary *node2 in nodeChild)
                {
                    NSString *nodeName = nil, *nodeContent = nil;
                    nodeName = (NSString*)[node2 valueForKey:@"nodeName"];
                    nodeContent = (NSString*)[node2 valueForKey:@"nodeContent"];
                    
                    if ([nodeName isEqualToString:@"observation_time"]) weather.CurrentTime = nodeContent;
                    else
                        if ([nodeName isEqualToString:@"temp_C"]) weather.nTempC = [nodeContent integerValue];
                        else
                            if ([nodeName isEqualToString:@"humidity"]) weather.nHumidity = [nodeContent integerValue];
                            else
                                if ([nodeName isEqualToString:@"windspeedKmph"]) weather.nWindSpeedKmph = [nodeContent integerValue];
                                else
                                    if ([nodeName isEqualToString:@"winddir16Point"]) weather.WindDirPoint = nodeContent;
                                    else
                                        if ([nodeName isEqualToString:@"weatherDesc"]) weather.WeatherDesc = nodeContent;
                                        else
                                            if ([nodeName isEqualToString:@"winddirDegree"]) weather.nWindDir = [nodeContent integerValue];
                    
                    /*for (id key2 in node2)
                    {
                        if ( [key2 isEqualToString: @"nodeName"] ) nodeName = [node2 objectForKey:key2];
                        else
                        if ([key2 isEqualToString: @"nodeContent"])
                        {
                        }
                        else
                        if ([key2 isEqualToString: @"nodeChildArray"])
                        {
                            if ([nodeName isEqualToString:@"weatherIconUrl"])
                            {
                                NSArray *node_weatherIconUrl = (NSArray*)[node2 objectForKey:key2];
                                weather.weatherIconUrl = [self fetchContent: node_weatherIconUrl];
                            }
                            else
                            if ([nodeName isEqualToString:@"weatherDesc"])
                            {
                                NSArray *node_weatherDesc = (NSArray*)[node2 objectForKey:key2];
                                weather.WeatherDesc = [self fetchContent: node_weatherDesc];                                
                            }
                        }
                    }*/
                }
            }
        }
    }
    
    return YES;
}

- (bool) GetWeatherForDay: (NSInteger) index toItem: (wsWeathDate*)item
{
    if (m_bLoading == YES) return !m_bLoading;
    
    NSString *xpathQueryString = nil;
    NSArray *nodes = nil;
    
    [item clear];
    
    // Город
    xpathQueryString = @"/child::data/child::request/child::query";
    nodes = PerformXMLXPathQuery(responseData, xpathQueryString);
    item.CurrentCity = [self fetchContent:nodes];
    
    // Погодные условия для дня по счету
    xpathQueryString = [NSString stringWithFormat:@"/child::data/child::weather[position()=%d]", (int)(index+1)];
    nodes = PerformXMLXPathQuery(responseData, xpathQueryString);
    
    for (NSDictionary *node in nodes)
    {
        NSString *nodeName = @"";
        for (id key in node)
        {
            if ( [key isEqualToString: @"nodeName"] ) nodeName = [node objectForKey:key];
            else
                if ([key isEqualToString: @"nodeChildArray"])
                {
                    NSArray *nodeChild = (NSArray*)[node objectForKey:key];
                    for (NSDictionary *node2 in nodeChild)
                    {
                        NSString *nodeName = @"";
                        for (id key2 in node2)
                        {
                            if ( [key2 isEqualToString: @"nodeName"] ) nodeName = [node2 objectForKey:key2];
                            else
                                if ([key2 isEqualToString: @"nodeContent"])
                                {
                                    if ([nodeName isEqualToString:@"date"]) item.ForDate = [node2 objectForKey:key2];
                                    else if ([nodeName isEqualToString:@"tempMaxC"]) item.nTempMaxC = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"tempMaxF"]) item.nTempMaxF = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"tempMinC"]) item.nTempMinC = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"tempMinF"]) item.nTempMinF = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"windspeedMiles"]) item.nWindSpeedMiles = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"windspeedKmph"]) item.nWindSpeedKmph = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"winddirection"]) item.sWindDirection = [node2 objectForKey:key2];
                                    else if ([nodeName isEqualToString:@"winddir16Point"]) item.sWindDir16Point = [node2 objectForKey:key2];
                                    else if ([nodeName isEqualToString:@"winddirDegree"]) item.nWindDirDegree = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"weatherCode"]) item.nWeatherCode = [(NSString*)[node2 objectForKey:key2] integerValue];
                                    else if ([nodeName isEqualToString:@"precipMM"]) item.fPrecipMM = [(NSString*)[node2 objectForKey:key2] doubleValue];
                                    else if ([nodeName isEqualToString:@"weatherDesc"]) item.WeatherDesc = [node2 objectForKey:key2];
                                }
                                else
                                if ([key2 isEqualToString: @"nodeChildArray"])
                                {
                                    if ([nodeName isEqualToString:@"weatherIconUrl"])
                                    {
                                        NSArray *node_weatherIconUrl = (NSArray*)[node2 objectForKey:key2];
                                        item.weatherIconUrl = [self fetchContent: node_weatherIconUrl];
                                    }
                                    else
                                    if ([nodeName isEqualToString:@"weatherDesc"])
                                    {
                                        NSArray *node_weatherDesc = (NSArray*)[node2 objectForKey:key2];
                                        item.WeatherDesc = [self fetchContent: node_weatherDesc];
                                    }
                                }
                        }
                    }
                }
        }
    }
    
    return YES;
}

- (bool) getSearchLocations:(NSMutableArray**) arrSearch Error: (NSError**)error
{
    NSString *log = [NSString stringWithFormat:@"%s", (char*)[responseData mutableBytes]];
    NSLog(@"%@", log);
    
    SBJson4Parser *jsonparser = nil;
    
    SBJson4ValueBlock jsonvalueblock = ^(id v, BOOL *stop)
    {
        NSMutableDictionary *search_api = nil;
        
        if ([v isKindOfClass: [NSMutableDictionary class]])
        {
            search_api = (NSMutableDictionary *)v;
            id search_api_result = nil;
            search_api_result = [search_api objectForKey:@"search_api"];
            if (search_api_result == NULL)
            {
                (*stop = YES);
                return;
            }
            if ([search_api_result isKindOfClass: [NSMutableDictionary class]])
            {
                NSMutableDictionary *result = (NSMutableDictionary *)search_api_result;
                id result_value = nil;
                result_value = [result objectForKey:@"result"];
                if (result_value == NULL)
                {
                    (*stop = YES);
                    return;
                }
                if ([result_value isKindOfClass: [NSMutableArray class]])
                {
                    NSMutableArray *result_array = (NSMutableArray *)result_value;
                    for (int i=0; i<[result_array count]; i++)
                    {
                        NSString *areaName = nil, *country = nil;
                        
                        id result_item = [result_array objectAtIndex:i];
                        if ([result_item isKindOfClass:[NSMutableDictionary class]])
                        {
                            NSMutableDictionary *item_dictionaty = (NSMutableDictionary*)result_item;
                            
                            id array_value = [item_dictionaty objectForKey:@"areaName"];
                            if ([array_value isKindOfClass: [NSMutableArray class]])
                            {
                                NSMutableArray *arrayItem = (NSMutableArray *)array_value;
                                if ([arrayItem count])
                                {
                                    NSMutableDictionary *dict_dict = (NSMutableDictionary *)[arrayItem objectAtIndex:0];
                                    areaName = (NSString*)[dict_dict objectForKey: @"value"];
                                }
                            }
                            array_value = [item_dictionaty objectForKey:@"country"];
                            if ([array_value isKindOfClass: [NSMutableArray class]])
                            {
                                NSMutableArray *arrayItem = (NSMutableArray *)array_value;
                                if ([arrayItem count])
                                {
                                    NSMutableDictionary *dict_dict = (NSMutableDictionary *)[arrayItem objectAtIndex:0];
                                    country = (NSString*)[dict_dict objectForKey: @"value"];
                                }
                            }
                            
                            sCity *city = nil;
                            city = [[sCity alloc] init];
                            city.areaName = areaName;
                            city.country = country;
                            
                            [*arrSearch addObject: city];
                        }
                    }
                }
                else
                {
                    (*stop = YES);
                    return;
                }
            }
            else
            {
                (*stop = YES);
                return;
            }
        }
        else
        {
            (*stop = YES);
            return;
        }
        
    };
    
    SBJson4ProcessBlock jsonprocessbloc = ^(id item, NSString* path)
    {
        return item;
    };
    
    SBJson4ErrorBlock eh = ^(NSError* err)
    {
        NSLog(@"OOPS: %@", err);
    };
    
    jsonparser = [[SBJson4Parser alloc] initWithBlock:jsonvalueblock
                                        processBlock:jsonprocessbloc
                                        multiRoot:NO
                                        unwrapRootArray:YES
                                        maxDepth:32
                                        errorHandler:eh];
    [jsonparser parse: responseData];
    
    return YES;
}

#pragma mark NSURLConnection Delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error
{
    // Здесь должна быть реализована реакция на ошибки
    
    m_bLoading = NO;
    [self.delegate MakeRequestsFinished:self RequestType:m_reqType WithError:error];
    
    return;
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse
{
    @autoreleasepool {
        theURL = [request URL];
    }
    
    return request;
}

- (void) connection: (NSURLConnection*)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
    
    long expectLength = [response expectedContentLength];
    
    [self.delegate RequestExpectedLength: self ExpectedLength: expectLength];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData: data];
    
    [self.delegate RequestDidRecieveBytes:self RecieveBytes:data.length];
}

- (void) connectionDidFinishLoading: (NSURLConnection*)connection
{
    m_bLoading = NO;
    
    [self.delegate MakeRequestsFinished:self RequestType:m_reqType WithError: nil];
}

/*
*/
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    return;
}

@end
