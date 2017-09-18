//
//  WSCityWeathCell.m
//  Skyward
//
//  Created by Сергей Швакель on 29.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSCityWeathCell.h"
#import "WSCityWeathCellViewContext.h"

@implementation WSCityWeathCell

@synthesize controller = _controller;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier weathData:(wsWeath*)weathData
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        CGRect initRect = self.contentView.bounds;
        
        cellContentView = [[WSCityWeathCellViewContext alloc] initWithFrame:initRect/*(self.contentView.bounds, 0.0, 1.0)*/ cell:self];
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeRedraw;
        
        [self.contentView addSubview:cellContentView];
        
        CGFloat fHeight1 = initRect.size.height/14;
        CGFloat fWidth1 = initRect.size.width/8;
        
        CGFloat xpos = 0.0, ypos = 0.0, width = 0.0, height = 0.0;
        xpos = 0.0;
        ypos = 7*fHeight1;
        width = 4*fWidth1;
        height = 5*fHeight1;
        
        thermometrView = [[wsElemTherm alloc] initWithFrame: CGRectMake(xpos, ypos, width, height)];
        thermometrView.autoresizingMask = UIViewAutoresizingNone;
        [self.contentView addSubview:thermometrView];
        
        data = weathData;
        thermometrView.Temperature = data.nTempC;
        
        // Положение кнопки "Обновить"
        // Высота кнопки: 2/14 высоты (книжный)
        // Ширина кнопки: 50
        // Расположение по центру
        xpos = (initRect.size.width/2)-25;
        ypos = fHeight1*12;
        width = 50;
        height = fHeight1*2;
        
        //butRefresh = [[UIButton alloc] initWithFrame:CGRectMake(xpos, ypos, width, height)];
        butRefresh = [UIButton buttonWithType:UIButtonTypeCustom];
        [butRefresh setFrame: CGRectMake(xpos, ypos, width, height)];
        [butRefresh setTitle:@"Обновить" forState:UIControlStateNormal];
        
        [butRefresh addTarget:self action:@selector(actionTapRefresh) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:butRefresh];
        
    }
    
    return self;
}

- (void) setData: (wsWeath*) WeathData
{
    data = WeathData;
    thermometrView.Temperature = data.nTempC;
    
    [cellContentView setNeedsDisplay];
    [thermometrView setNeedsDisplay];
}

- (void) actionTapRefresh
{
    if (self.controller)
        [self->_controller refreshWeath];
    return;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Вычисляем расположение термометра с текущей температурой
    // в зависимости от положения устройства
    UIDevice *device = [UIDevice currentDevice];
    if (device.orientation == UIDeviceOrientationUnknown ||
        device.orientation == UIDeviceOrientationPortrait)
    {
        CGRect initRect = self.contentView.bounds;
        
        cellContentView.frame = initRect;
        
        CGFloat fHeight1 = initRect.size.height/14;
        CGFloat fWidth1 = initRect.size.width/8;
        
        CGFloat xpos = 0.0, ypos = 0.0, width = 0.0, height = 0.0;
        xpos = 0.0;
        ypos = 7*fHeight1;
        width = 4*fWidth1;
        height = 5*fHeight1;
        
        thermometrView.frame = CGRectMake(xpos, ypos, width, height);
        
        // Положение кнопки "Обновить"
        // Высота кнопки: 2/14 высоты (книжный)
        // Ширина кнопки: 50
        // Расположение по центру
        xpos = (initRect.size.width/2)-25;
        ypos = fHeight1*12;
        width = 50;
        height = fHeight1*2;
        
        [butRefresh setFrame: CGRectMake(xpos, ypos, width, height)];
    }    
}

@end
