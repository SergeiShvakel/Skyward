//
//  WSMainViewController.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSFlipsideViewController.h"
#import "WSModelDelegate.h"

#import "ViewElements/wsElemTherm.h"

@interface WSMainViewController : UIViewController <WSFlipsideViewControllerDelegate, WSModelDelegate>
{
    WSModel *model;
}

- (id) initWithModel: (WSModel*)model_l;

- (IBAction)showInfo:(id)sender;
- (IBAction)Refresh:(id)sender;

@property (weak, nonatomic) WSModel *model;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *m_LoadingActivity;

@property (strong, nonatomic) IBOutlet UILabel *m_CityName;
@property (strong, nonatomic) IBOutlet UILabel *m_CurrentTime;

@property (strong, nonatomic) IBOutlet UIImageView *m_NowImage;
@property (strong, nonatomic) IBOutlet UILabel *m_NowTemp;
@property (strong, nonatomic) IBOutlet UILabel *m_NowHumidity;
@property (strong, nonatomic) IBOutlet UILabel *m_NowWind;
@property (strong, nonatomic) IBOutlet UILabel *m_NowCondition;

@property (strong, nonatomic) IBOutlet wsElemTherm *m_NowElemTherm;

@end
