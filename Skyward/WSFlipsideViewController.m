//
//  WSFlipsideViewController.m
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSFlipsideViewController.h"

@interface WSFlipsideViewController ()

@end

@implementation WSFlipsideViewController

@synthesize m_Progress;
@synthesize m_LoadingLab;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_MaxLength = 0;
    m_Progress.progress = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setMaxLength: (long)maxLength
{
    if (maxLength < 0) {
        m_MaxLength = 0;
    }
    else
        m_MaxLength = maxLength;
    m_Progress.progress = 0.0;
    
    NSString *strTemp = nil;
    strTemp = [[NSBundle mainBundle] localizedStringForKey:@"STR_LOADING_LABEL" value:nil table:@"InfoPlist"];
    if (strTemp == nil)
        strTemp = [NSString stringWithFormat:@"Not found for key=%@ in localized table", @"STR_LOADING_LABEL"];
    NSString *mess = [[NSString alloc] initWithFormat: strTemp, 0];
    
    m_LoadingLab.text = mess;
}

- (void) setCurPos: (long)pos
{
    float fpos = 0.0;
    
    if (m_MaxLength != 0)
        fpos = (float)pos/m_MaxLength;
    else
        fpos = 1.0;
    if (fpos > 1) fpos = 1.0;
    m_Progress.progress = fpos;
    
    NSString *strTemp = nil;
    strTemp = [[NSBundle mainBundle] localizedStringForKey:@"STR_LOADING_LABEL" value:nil table:@"InfoPlist"];
    if (strTemp == nil)
        strTemp = [NSString stringWithFormat:@"Not found for key=%@ in localized table", @"STR_LOADING_LABEL"];
    NSString *mess = [[NSString alloc] initWithFormat: strTemp, (int)(fpos*100)];
    
    m_LoadingLab.text = mess;
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
