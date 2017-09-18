//
//  SWCityAddController.h
//  Skyward
//
//  Created by Сергей Швакель on 09.11.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../SkyModel/WSModel.h"

#import "SWWaitProgressController.h"
#import "WSFlipsideViewController.h"

@interface SWCityAddController : UIViewController <WSModelDelegate, WSFlipsideViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    WSModel *m_Model;
    
    IBOutlet UITableView *m_TabView;
    IBOutlet UITableViewCell *m_cellInputFindLoaction;  // Ячейка для ввода местоположения для поиска
    IBOutlet UITableViewCell *m_cellButtonSearch;       // Ячейка с кнопкой поиска
    IBOutlet UITableViewCell *m_cellResult;             // Ячейка для отображения результатов поиска
    
    NSString *m_Location;       // Введеное название города для поиска
    NSArray *m_arrSearchRes;    // список найденных городов по запросу
    
    bool    m_NoResultSearch;   // Флаг, 1 - если поиск не дал результат
    
    NSThread *m_loadingThread;  // Отдельный поток для загрузки данных
    
    WSFlipsideViewController *flipcontroller;
    //SWWaitProgressController *waitLoadingController;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model;

- (IBAction)actSearchBut:(id)sender;

- (void) FlipsideViewAppear;
- (void) threadParallelProc: (SWCityAddController*) controller;

@end
