//
//  SWCityResultSearchView.h
//  Skyward
//
//  Created by Сергей Швакель on 08.05.14.
//  Copyright (c) 2014 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWCityResultSearchCell.h"

@interface SWCityResultSearchView : UIView
{
    SWCityResultSearchCell *m_cell;
}

- (id)initWithFrame:(CGRect)frame Cell:(SWCityResultSearchCell*) cell;

@end
