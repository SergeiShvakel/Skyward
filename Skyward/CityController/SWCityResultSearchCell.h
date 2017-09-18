//
//  SWCityResultSearchCell.h
//  Skyward
//
//  Created by Сергей Швакель on 07.05.14.
//  Copyright (c) 2014 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sCity.h"
//#import "SWCityResultSearchView.h"


@interface SWCityResultSearchCell : UITableViewCell
{
    UIView *m_viewCell;
    sCity *m_location;
}

@property (readonly, nonatomic) sCity *m_location;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLocation:(sCity*) location;
- (void) setLocation:(sCity*)location;

@end
