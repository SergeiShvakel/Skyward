//
//  SWCityResultSearchCell.m
//  Skyward
//
//  Created by Сергей Швакель on 07.05.14.
//  Copyright (c) 2014 Сергей Швакель. All rights reserved.
//

#import "SWCityResultSearchCell.h"
#import "SWCityResultSearchView.h"

@implementation SWCityResultSearchCell

@synthesize m_location;

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithLocation:(sCity*) location;
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        m_location = [location copy] ;
        
        CGRect screenRect, viewOrigin;
        screenRect = [UIScreen mainScreen].applicationFrame;
        
        viewOrigin.origin = CGPointMake(0,0);
        viewOrigin.size = CGSizeMake(screenRect.size.width, 50);
        
        m_viewCell = [[SWCityResultSearchView alloc] initWithFrame:viewOrigin Cell:self];
        if (m_viewCell)
        {
            [self.contentView addSubview:m_viewCell];
        }
    }
    
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) dealloc
{
    m_location = nil;
}

- (void) setLocation:(sCity*)location
{
    m_location = [location copy];
    [m_viewCell setNeedsDisplay];
}

@end
