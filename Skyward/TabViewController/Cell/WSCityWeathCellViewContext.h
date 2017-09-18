//
//  WSCityWeathCellViewContext.h
//  Skyward
//
//  Created by Сергей Швакель on 29.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSCoreCell.h"

@interface WSCityWeathCellViewContext : UIView
{
    WSCoreCell *_cell;
    BOOL _highlighted;
    
    CGLayerRef m_layStat;
    
    CGPathRef m_pathArrow; // Стрелка указатель направления ветра
}

- (id)initWithFrame:(CGRect)frame cell:(WSCoreCell*)cell;

@end
