//
//  WSCityWeathCell.h
//  Skyward
//
//  Created by Сергей Швакель on 29.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WSCoreCell.h"
#import "wsElemTherm.h"
#import "WSControllerTabView.h"

@interface WSCityWeathCell : WSCoreCell
{
    UIView   *cellContentView;
    UIButton *butRefresh;
    
    wsElemTherm *thermometrView;
}

@property (nonatomic, weak) WSControllerTabView *controller;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier weathData:(wsWeath*)weathData;

- (void) setData: (wsWeath*) WeathData;

@end
