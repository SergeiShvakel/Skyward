//
//  WSModel.m
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSModel.h"
#import "WSWorldWeatherRequest.h"
#import "sCity.h"
#import "TextExchange.h"

@implementation WSModel
{
}

@synthesize delegate;
@synthesize m_CurrWeather;
@synthesize m_WeatherForDate;
@synthesize m_LastSearchLocation;
@synthesize m_lastIDLocation;

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        m_DaysCount = 1;
        
        m_CurrWeather = [[wsWeath alloc] init];
        
        m_WeatherForDate    = [[NSMutableArray alloc] init];
        m_WeatherSource     = [[WSWorldWeatherRequest alloc] initWith:self];
        
        m_FaivoritCities    = nil;
        m_sFaivoritFileName = @"SkyFaivoriteCities.txt";
        
        m_lastIDLocation    = 0;

        m_LastSearchLocation = nil;
    }
    
    return self;
}

- (void) dealloc
{
    delegate = nil;
}

- (bool) isNeedUpdateWeathForecast:(NSUInteger)IDLocation
{
    if (m_CurrWeather)
    {
        if (m_CurrWeather.IDLocation != IDLocation)
            return true;
    }
    
    return false;
}

- (bool) loadWeathForecast: (NSUInteger) IDLocation
{
    NSUInteger indexToLoad = 0;
    if (IDLocation > 0 && IDLocation <= m_FaivoritCities.count)
        indexToLoad = IDLocation-1;
    else
        return NO;
    
    sCity *item = [m_FaivoritCities objectAtIndex:indexToLoad];
    
    if (item.areaName && [item.areaName length] > 0)
    {
        // Выполняем запрос последнего просматриваемого города
        NSString *location = nil;
        location = [NSString stringWithString:item.areaName];
        
        if (item.country && [item.country length] > 0)
        {
            location = [location stringByAppendingFormat:@",%@", item.country];
        }
        
        [m_CurrWeather clear];
        m_CurrWeather.IDLocation = IDLocation;
        [m_WeatherSource MakeForecastRequest: location forDay: m_DaysCount];
        
        m_lastIDLocation = IDLocation;
        return YES;
    }
    
    return NO;
}

- (void) LoadData
{
    // 1. Загружаем сохраненные города
    [self loadFaivoritLocations];

    // 2. Загружаем погоду для текущего местоположения
    if ([self loadWeathForecast: m_lastIDLocation] == NO)
        [delegate LoadingInitialDataDidFinish:self];
}

- (void) loadLocations:(NSString*) location
{
    [m_WeatherSource MakeFindLocationRequest: location];
}

- (void) loadFaivoritLocations
{
    NSString *sFullPath = nil;
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [arrayPaths objectAtIndex:0];
    
    //NSLog(@"%@", docDirectory);
    
    sFullPath = [docDirectory stringByAppendingPathComponent:m_sFaivoritFileName];
    
    // 1. Чтение данных из файла приложений
    NSString *strFaivoritCity;
    NSStringEncoding strEnc = 0;
    NSError *lastError = nil;
    lastError = [[NSError alloc] init];
    
    strFaivoritCity = [[NSString alloc] initWithContentsOfFile: sFullPath usedEncoding: &strEnc error: &lastError];
    /*if (strFaivoritCity == nil)
    {
        NSString *strlocal = nil;
        strlocal = [[NSBundle mainBundle] localizedStringForKey:@"STR_FAIVORITE_FILE_NOT_FOUND" value:nil table:@"InfoPlist"];
        if (strlocal == nil)
            strlocal = [NSString stringWithFormat:@"Not found for key=%@ in localized table", @"STR_FAIVORITE_FILE_NOT_FOUND"];
        
        NSString *mess = [[NSString alloc] initWithFormat: strlocal, m_sFaivoritFileName];
        
        UIAlertView *messBox = [[UIAlertView alloc]
                                initWithTitle:@"Error"
                                message:mess
                                delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"Ok", nil];
        [messBox show];
    }*/
    if (strFaivoritCity != nil)
    {
        // 2. Парсинг данных из файла
        cTextExchange *textExchange = nil;
        textExchange = [[cTextExchange alloc] initWithString:strFaivoritCity];
        
        cTextExchange *FaivorBlock = nil;
        FaivorBlock = [[cTextExchange alloc] init];
        NSString *strBlock = @"";
        [textExchange GetOptField:@"Faivorite" OutData:&strBlock];
        [FaivorBlock SetDataBuffer:strBlock];
        
        for (bool bFind = [FaivorBlock FindFirstBlock:@"Location" OutData:&strBlock];
             bFind;
             bFind = [FaivorBlock FindNextBlock:&strBlock])
        {
            cTextExchange *LocationBlock = [[cTextExchange alloc] initWithString:strBlock];
            
            sCity *itemLocation = [[sCity alloc] init];
            
            NSString *value = @"";
            if ([LocationBlock GetNeedField:@"AreaName" OutData:&value] == TXTEXCHANGE_ERR_NOERROR)
                itemLocation.areaName = value;
            if ([LocationBlock GetNeedField:@"Country" OutData:&value] == TXTEXCHANGE_ERR_NOERROR)
                itemLocation.country = value;
            
            [self addFaivoriteLocations:itemLocation];
        }
    }
}

- (void) saveFaivoritLocations
{
    NSString *sFullPath = nil;
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [arrayPaths objectAtIndex:0];
    
    sFullPath = [docDirectory stringByAppendingPathComponent: m_sFaivoritFileName];
    
    BOOL bMustCreateFile = FALSE;
    BOOL bNoAccessToWrite = FALSE;
    
    //1. Проверяем наличие файла и при необходимости создаем его
    NSFileManager *fileman = [[NSFileManager alloc] init];
    NSString *currPath = [fileman currentDirectoryPath];
    NSError *lastError = nil;
    lastError = [[NSError alloc] init];
    
    NSArray *contentsOfDir = nil;
    contentsOfDir = [fileman contentsOfDirectoryAtPath:currPath error:&lastError];
    
    BOOL isDir = FALSE;
    if ([fileman fileExistsAtPath:docDirectory isDirectory:&isDir] && isDir)
    {
        bMustCreateFile = TRUE;
    }
    
    if ([fileman fileExistsAtPath:sFullPath] == NO)
    {
        bMustCreateFile = TRUE;
    }
    else
    {
        if ([fileman isWritableFileAtPath:sFullPath] == NO)
            bNoAccessToWrite = TRUE;
    }
    
    if (bMustCreateFile)
    {
        NSString *strEmpty = @"empty";
        unichar *strBuff = nil;
        NSUInteger strBuffLen = [strEmpty lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
        strBuff = malloc(strBuffLen);
        NSRange range;
        range.location=0;
        range.length=[strEmpty length];
        [strEmpty getBytes:strBuff
                    maxLength:strBuffLen
                    usedLength:nil
                    encoding:NSUnicodeStringEncoding
                    options:NSStringEncodingConversionAllowLossy
                    range:range
                    remainingRange:nil];
        
        NSData *contents = [NSData dataWithBytes:strBuff length:strBuffLen];
        if ([fileman createFileAtPath:sFullPath contents:contents attributes:nil] == NO)
            bNoAccessToWrite = TRUE;
        
        free(strBuff);
    }
    
    if (bNoAccessToWrite == TRUE) // если запись в файл не возможна, то выход
        return;
    
    NSString *strToWrite = nil;
    
    // Формирование буфера для записи
    cTextExchange *cExchLocation = nil;
    cExchLocation = [[cTextExchange alloc] init];
    
    for (int i = 0; i < [m_FaivoritCities count]; i++)
    {
        sCity *item = [m_FaivoritCities objectAtIndex:i];
        
        cTextExchange *cExch = nil;
        cExch = [[cTextExchange alloc] init];
        
        [cExch AddField:@"AreaName" StrValue:item.areaName];
        [cExch AddField:@"Country" StrValue:item.country];
        
        [cExchLocation AddField:@"Location" StrValue:[cExch GetDataBuffer]];
    }
    
    cTextExchange *cExchBlock = [[cTextExchange alloc] init];
    [cExchBlock AddOptField:@"Faivorite" StrValue:[cExchLocation GetDataBuffer]];
    
    strToWrite = [NSString stringWithString:[cExchBlock GetDataBuffer]];
    
    if ([strToWrite writeToFile:sFullPath atomically:YES encoding:NSUnicodeStringEncoding error: &lastError] == NO)
    {
        NSString *strlocal = nil;
        strlocal = [[NSBundle mainBundle] localizedStringForKey:@"STR_FAIVORITE_FILE_NOT_FOUND" value:nil table:@"InfoPlist"];
        if (strlocal == nil)
            strlocal = [NSString stringWithFormat:@"Not found for key=%@ in localized table", @"STR_FAIVORITE_FILE_NOT_FOUND"];
        
        NSString *mess = [[NSString alloc] initWithFormat: strlocal, m_sFaivoritFileName];
        
        UIAlertView *messBox = [[UIAlertView alloc]
                                initWithTitle:@"Error"
                                message:mess
                                delegate:nil
                                cancelButtonTitle:nil
                                otherButtonTitles:@"Ok", nil];
        [messBox show];
    }
}

- (NSUInteger) getCountCity
{
    return [m_FaivoritCities count];
}

- (sCity*) getCity: (NSUInteger) index
{
    if (index < [m_FaivoritCities count])
        return [m_FaivoritCities objectAtIndex:index];
    
    return nil;
}

- (bool) addFaivoriteLocations:(sCity*)location
{
    NSMutableArray *tempArray = nil;
    
    tempArray = [[NSMutableArray alloc] initWithArray:m_FaivoritCities];
    [tempArray addObject:location];
    
    m_FaivoritCities = [[NSArray alloc] initWithArray:tempArray];
    
    // Добавленный город - будет текущим
    m_lastIDLocation = [m_FaivoritCities count];
    
    return true;
}

#pragma mark WSIWeatherRequestDelegate Methods

- (void) MakeRequestsFinished: (id<WSIWeatherRequest>) source RequestType: (NSInteger)reqType WithError:(NSError *)error
{
    if (error == nil)
    {
        // запрос погоды
        if (reqType == SW_FORECAST_REQ)
        {
            // данные текущего состояния
            [m_WeatherSource GetCurrentWeather: m_CurrWeather];
            // данные по будущим дням
            for (int i = 0; i < m_DaysCount; i++)
            {
                wsWeathDate *item = nil;
                item = [[wsWeathDate alloc] init];
                [m_WeatherSource GetWeatherForDay: i toItem: item];
        
                //[m_WeatherForDate addObject:item];
            }
        }
        else
            // выбор текущего местоположени
            if (reqType == SW_SEARCH_REQ)
            {
                NSMutableArray *arrSearch = [[NSMutableArray alloc] init];
                NSError *error = nil;
        
                error = [[NSError alloc] init];
                [m_WeatherSource getSearchLocations: &arrSearch Error:&error];
        
                m_LastSearchLocation = arrSearch;
            }
    }
    
    [delegate LoadingRequestDidFinish:self RequestType: reqType WithError: error];
}

- (void) RequestExpectedLength: (id<WSIWeatherRequest>) source  ExpectedLength: (long) expLength
{
    [delegate LoadingRequestExpectLength:self ExpectLength:expLength];
}

- (void) RequestDidRecieveBytes: (id<WSIWeatherRequest>) source  RecieveBytes: (long) recieveBytes
{
    [delegate LoadingRequestGetBytes:self GetBytes:recieveBytes];
}

@end
