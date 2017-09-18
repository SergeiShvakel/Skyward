//
//  WSMainViewController.m
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSMainViewController.h"
#import "WSAppDelegate.h"

@interface WSMainViewController ()

@end

@implementation WSMainViewController

@synthesize model=_model;

@synthesize m_LoadingActivity;
@synthesize m_CityName;
@synthesize m_CurrentTime;
@synthesize m_NowTemp;
@synthesize m_NowImage;
@synthesize m_NowHumidity;
@synthesize m_NowWind;
@synthesize m_NowCondition;

@synthesize m_NowElemTherm;

- (id) initWithModel: (WSModel*)model_l
{
    self = [super initWithNibName:@"WSMainViewController" bundle:nil];
    if (self)
    {
        self.model = model_l;        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self Refresh:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(WSFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showInfo:(id)sender
{    
    WSFlipsideViewController *controller = [[WSFlipsideViewController alloc] initWithNibName:@"WSFlipsideViewController" bundle:nil];
    controller.delegate = self;
    controller.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)Refresh:(id)sender
{
    WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
    app.m_Model.delegate = self;
    
    m_LoadingActivity.hidesWhenStopped = YES;
    [m_LoadingActivity startAnimating];
    [app.m_Model LoadData];
}

- (void) LoadingRequestDidFinish:(WSModel*)model
{
    [m_LoadingActivity stopAnimating];
    
    m_CityName.text = self.model.m_CurrWeather.CurrentCity;
    m_CurrentTime.text = self.model.m_CurrWeather.CurrentTime;
    
    m_NowTemp.text = [NSString stringWithFormat:@"%02d℃", self.model.m_CurrWeather.nTempC];
    m_NowHumidity.text = [NSString stringWithFormat:@"%2d%%", self.model.m_CurrWeather.nHumidity];
    
    NSURL *url = [NSURL URLWithString:self.model.m_CurrWeather.weatherIconUrl];
    NSData *data = [NSData dataWithContentsOfURL:url];
    m_NowImage.image = [[UIImage alloc] initWithData:data];
    
    m_NowWind.text = [NSString stringWithFormat:@"%s at %d kmph", [self.model.m_CurrWeather.WindDirPoint cStringUsingEncoding: NSUTF8StringEncoding], self.model.m_CurrWeather.nWindSpeedKmph];
    m_NowCondition.text = self.model.m_CurrWeather.WeatherDesc;
    
    [m_NowElemTherm setNeedsDisplay];
    
    return;
}

@end
