//
//  sCity.m
//  Skyward
//
//  Created by Сергей Швакель on 17.07.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "sCity.h"

@implementation sCity

@synthesize areaName;
@synthesize country;

-(id)copyWithZone:(NSZone*)zone
{
    id copy = [[[self class] allocWithZone:zone] init];
    
    [copy setAreaName:[self areaName]];
    [copy setCountry:[self country]];
    
    return copy;
}

@end
