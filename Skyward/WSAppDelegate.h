//
//  WSAppDelegate.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SkyModel/WSModel.h"

@class WSStartViewController;
@class WSMainViewController;

@interface WSAppDelegate : UIResponder <UIApplicationDelegate>
{
    WSModel *m_Model;
    
    WSStartViewController *m_WSStartView;       // Стартовая страница
    
    UITabBarController *m_SWTabBar;             // Контроллер с закладками (отображает текущую погоду, настройки и др.)
    UINavigationController *m_SWNavController;  // Контроллер для окон с навигацией
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController        *m_SWTabBar;
@property (strong, nonatomic) UINavigationController    *m_SWNavController;

//@property (strong, nonatomic) WSMainViewController *mainViewController;
@property (strong, nonatomic) WSModel *m_Model;

- (void) showWeatherView;
- (void) showManageLocationsView;

@end
