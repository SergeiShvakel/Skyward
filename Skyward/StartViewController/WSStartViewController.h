//
//  WSStartViewController.h
//  Skyward
//
//  Created by Сергей Швакель on 30.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSModelDelegate.h"

@interface WSStartViewController : UIViewController <WSModelDelegate>
{
    NSThread *m_loadingThread;  // Отдельный поток для инициализации класса модели
    //NSString *notificationStopThreadName;
}

@end
