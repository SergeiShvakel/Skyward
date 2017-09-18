//
//  SWCityManageController.m
//  Skyward
//
//  Created by Сергей Швакель on 07.11.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "sCity.h"
#import "SWCityManageController.h"
#import "SWCityAddController.h"

#import "WSAppDelegate.h"

@interface SWCityManageController ()

@end

@implementation SWCityManageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        m_Model = _model;
        
        m_TableView = nil;
        
        m_bIsEditing = FALSE;
        
        CGRect winRect;
        UIScreen *pscreen = nil;
        pscreen = [UIScreen mainScreen];
        winRect = pscreen.bounds;
        
        m_TableView = [[UITableView alloc] initWithFrame: winRect style: UITableViewStylePlain];
        m_TableView.dataSource  = self;
        m_TableView.delegate    = self;
        m_TableView.allowsSelectionDuringEditing = YES;
        
        self.view = m_TableView;
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
        m_Model.delegate = self;
    }
    return self;
}

- (void) setEditableMode: (BOOL) isEditing
{
    [self setEditing:isEditing animated:TRUE];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    // Заголовок
    NSString *strTitle = nil;
    strTitle = [[NSBundle mainBundle] localizedStringForKey:@"CITY_MANAGE_CONTROLLER_TITLE" value:nil table:@"InfoPlist"];
    assert(strTitle);
    self.title = strTitle;
    
    [m_TableView reloadData];
}

/*
    Метод реагирует на нажатие кнопки Edit/Done
*/
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing != self.editing)
    {
        [super setEditing:editing animated:animated];
        
        [m_TableView setEditing:editing animated:animated];
        //[mTableView reloadData];
        
        NSIndexPath *newIndex = [NSIndexPath indexPathForRow: [m_Model getCountCity] inSection:0];
        NSArray *indexes = [NSArray arrayWithObject:newIndex];
        
        m_bIsEditing = self.isEditing;
        
        if (editing == YES)
        {
            [m_TableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [m_TableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
            
            // Сохраняем полученные города
            [m_Model saveFaivoritLocations];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate Method

- (void)
tableView:(UITableView *)tV didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_bIsEditing)
    {
        if (indexPath.row == [m_Model getCountCity])
        {
            // Вызываем представление добавления новой ячейки
            WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
        
            NSString *commonDictionaryPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"SWCityAddController" ofType:@"xib"];
            commonDictionaryPath = [commonDictionaryPath stringByDeletingLastPathComponent];
            NSBundle *resoureBundle = [[NSBundle alloc] initWithPath:  commonDictionaryPath];
        
            [tV deselectRowAtIndexPath:indexPath animated: YES];
            
            SWCityAddController *citycontr = [[SWCityAddController alloc] initWithNibName:@"SWCityAddController" bundle:resoureBundle model:m_Model];
            [app.m_SWNavController pushViewController: citycontr animated: YES];
        }
    }
    else
    {
        [tV deselectRowAtIndexPath:indexPath animated: YES];
        
        WSAppDelegate *app = (WSAppDelegate *)[[UIApplication sharedApplication] delegate];
        [app showWeatherView];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [m_Model getCountCity])
    {
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
}

- (NSInteger)getRowCount:(UITableView*)tableView section: (NSInteger)section
{
    NSInteger nCount = 0;
    nCount = [m_Model getCountCity];
    
    if (m_bIsEditing == YES)
        nCount++;
    
    return nCount;
}

#pragma mark UITableViewDataSource Method

-(NSInteger)tableView:(UITableView *)tV numberOfRowsInSection:(NSInteger)section
{
    return [self getRowCount: tV section: section];
}

- (UITableViewCell *)tableView:(UITableView *)tV cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == [m_Model getCountCity])
    {
        if (nil == m_cellAdd)
        {
            m_cellAdd = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addcell"];
        }
        
        NSString *str = nil;
        str = [[NSBundle mainBundle] localizedStringForKey:@"CITY_MANAGE_CONTROLLER_ADD_CITY" value:nil table:@"InfoPlist"];
        
        m_cellAdd.textLabel.text = str;
        m_cellAdd.textLabel.textColor = [UIColor lightGrayColor];
        m_cellAdd.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell = m_cellAdd;
    }
    else
    {
        cell = [tV dequeueReusableCellWithIdentifier: @"cell"];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc]
                    initWithStyle: UITableViewCellStyleDefault reuseIdentifier: @"cell"];
        }
        
        sCity *rec = nil;
        rec = [m_Model getCity:[indexPath indexAtPosition: [indexPath length]-1]];
        
        cell.textLabel.text = rec.areaName;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //[tableViewModel DeleteCityByIndex: indexPath.row];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
