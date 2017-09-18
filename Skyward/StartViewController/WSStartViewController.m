//
//  WSStartViewController.m
//  Skyward
//
//  Created by Сергей Швакель on 30.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSStartViewController.h"
#import "WSAppDelegate.h"
#import "WSControllerTabView.h"

#import "SWCityManageController.h"

@interface WSStartViewController ()

@end

@implementation WSStartViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        //notificationStopThreadName = @"ThreadHasFinished";
        
        // Регистрируем обработчик события остановки потока
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(aThreadHasFinished:) name:notificationStopThreadName object:self];
        
    }
    return self;
}

/*
    Поток чтения данных в модель
*/
- (void) threadParallelProc
{
    WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
    BOOL exitNow = NO;
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    // Add the exitNow BOOL to the thread dictionary.
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
    
    // Загрузка данных
    [app.m_Model LoadData];
    
    while (!exitNow)
    {
        // Run the run loop but timeout immediately if the input source isn't waiting to fire.
        [runLoop runUntilDate:[NSDate date]];
        
        // Check to see if an input source handler changed the exitNow value.
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
    }
    
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
    app.m_Model.delegate = self;
    
    m_loadingThread = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(threadParallelProc)
                                        object:nil];
    [m_loadingThread start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) LoadingInitialDataDidFinish:(WSModel*)model;
{
    // Останавливаем поток
    [[m_loadingThread threadDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"ThreadShouldExitNow"];
    
    [self performSelectorOnMainThread:@selector(aThreadHasFinished:) withObject:model waitUntilDone:NO];
}

- (void) LoadingRequestExpectLength: (WSModel*)model  ExpectLength : (long)ExpectLength
{
    return;
}

- (void) LoadingRequestGetBytes: (WSModel*)model  GetBytes : (long)getBytes
{
    return;
}

- (void) LoadingRequestDidFinish:(WSModel*)model RequestType:(NSInteger)reqType WithError:(NSError *)error
{
    // Останавливаем поток
    [[m_loadingThread threadDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"ThreadShouldExitNow"];
    
    [self performSelectorOnMainThread:@selector(aThreadHasFinished:) withObject:model waitUntilDone:NO];
    
    if (error != nil)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                                                       message:error.localizedDescription
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

/*- (void)fireNotification
{
    NSNotification *notification = [NSNotification notificationWithName:notificationStopThreadName object:self];
    NSNotificationQueue *notificationQueue = nil;
    notificationQueue = [[NSNotificationQueue alloc] initWithNotificationCenter:[NSNotificationCenter defaultCenter]];
    
    [notificationQueue enqueueNotification:notification postingStyle:NSPostASAP];
}*/

/*
    Метод реагирует на событие остановки параллельного потока
*/
- (void) aThreadHasFinished:(id)object
{
    WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    WSModel *model = (WSModel *)(object);
    
    // Проверяем были ли загружены данные
    if ([model getCountCity] == 0) // ничего не загружено - должны перейти на форму добавления города
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        [app showManageLocationsView];
     
    }
    else
    {
        [self dismissViewControllerAnimated:NO completion:nil];
        [app showWeatherView];
    }
}

@end
