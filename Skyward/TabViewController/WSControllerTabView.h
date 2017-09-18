//
//  WSControllerTabView.h
//  Skyward
//
//  Created by Сергей Швакель on 20.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../SkyModel/WSModel.h"

#import "WSFlipsideViewController.h"

/*
    Контроллер отображения погоды: текущей и прогноза на следующие дни
    1 ячейка - текущая;
    2 ячейка - прогноз на следующие дни.
*/
@interface WSControllerTabView : UITableViewController <WSModelDelegate, WSFlipsideViewControllerDelegate>
{
    WSModel *m_Model;
    
    NSUInteger m_IDLocation;    // Текущий номер местоположения просмотра погоды
    
    NSThread *m_loadingThread;  // Отдельный поток для загрузки данных
    
    WSFlipsideViewController *flipcontroller;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model;

- (void) refreshWeath;

@end
