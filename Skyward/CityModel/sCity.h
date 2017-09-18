//
//  sCity.h
//  Skyward
//
//  Created by Сергей Швакель on 17.07.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface sCity : NSObject
{
    NSString *areaName; // Наименование города
    NSString *country;  // Страна
}

@property (nonatomic, copy) NSString *areaName;
@property (nonatomic, copy) NSString *country;

-(id)copyWithZone:(NSZone*)zone;

@end
