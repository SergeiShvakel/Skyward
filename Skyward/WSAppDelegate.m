//
//  WSAppDelegate.m
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSAppDelegate.h"

#import "WSControllerTabView.h"
#import "WSStartViewController.h"
#import "SWCityManageController.h"

@implementation WSAppDelegate

@synthesize m_Model;
@synthesize m_SWTabBar;
@synthesize m_SWNavController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    m_Model = [[WSModel alloc] init];
    m_SWTabBar = nil;
    m_SWNavController = nil;
    
    //WSMainViewController *mainViewController = nil;
    //mainViewController = [[WSMainViewController alloc] initWithModel:m_Model];
    
    //WSControllerTabView *controllerTabView = nil;
    //controllerTabView = [[WSControllerTabView alloc] initWithNibName:@"WSControllerTabView" bundle:nil];
    
    //m_SWTabBar = [[UITabBarController alloc] init];
    //m_SWTabBar.viewControllers = @[controllerTabView];
    
    m_WSStartView = [[WSStartViewController alloc] initWithNibName: @"WSStartViewController" bundle:nil];
    self.window.rootViewController = m_WSStartView;
    
    [self.window makeKeyAndVisible];
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Сохраняем города, полученные от пользователя
    [m_Model saveFaivoritLocations];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Сохраняем города, полученные от пользователя
    [m_Model saveFaivoritLocations];
}

- (void) showWeatherView
{
    if (self.m_SWTabBar == nil)
    {
        WSControllerTabView *controllerTabView = nil;
        controllerTabView = [[WSControllerTabView alloc] initWithNibName:@"WSControllerTabView" bundle:nil model:m_Model];
        
        self.m_SWTabBar = [[UITabBarController alloc] init];
        self.m_SWTabBar.viewControllers = @[controllerTabView];
    }
    
    self.window.rootViewController = self.m_SWTabBar;
    [self.window makeKeyAndVisible];
}

- (void) showManageLocationsView
{
    if (m_SWNavController == nil)
    {
        SWCityManageController *cityManageController = nil;
        cityManageController = [[SWCityManageController alloc] initWithNibName:@"SWCityManageController" bundle:nil model:m_Model];
        
        m_SWNavController = [[UINavigationController alloc]
                             initWithRootViewController:cityManageController
                            ];
        
        [cityManageController setEditableMode:TRUE];
    }
    
    self.window.rootViewController = m_SWNavController;
    [self.window makeKeyAndVisible];
}

@end
