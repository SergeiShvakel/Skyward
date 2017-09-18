//
//  WSCoreCell.h
//  Skyward
//
//  Created by Сергей Швакель on 29.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "wsWeath.h"

@interface WSCoreCell : UITableViewCell
{
    wsWeath *data;
}

@property (nonatomic) wsWeath *data;

@end
