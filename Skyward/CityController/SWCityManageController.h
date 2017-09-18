//
//  SWCityManageController.h
//  Skyward
//
//  Created by Сергей Швакель on 07.11.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../SkyModel/WSModel.h"

/*
    Контроллер отображения списка городов для просмотра погоды.
    Реализованы функции добавления/удаления городов.
*/

@interface SWCityManageController : UIViewController <WSModelDelegate, UITableViewDelegate, UITableViewDataSource>
{
    WSModel *m_Model;
    
    UITableView *m_TableView;
    
    BOOL m_bIsEditing;
    UITableViewCell *m_cellAdd;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model;

- (void) setEditableMode: (BOOL) isEditing;

@end
