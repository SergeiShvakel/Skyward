//
//  SWCityAddController.m
//  Skyward
//
//  Created by Сергей Швакель on 09.11.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSAppDelegate.h"
#import "SWCityAddController.h"
#import "SWWaitProgressController.h"

#import "WSFlipsideViewController.h"

#import "SWCityResultSearchCell.h"

@class WSFlipsideViewController;

@interface SWCityAddController ()

@end

@implementation SWCityAddController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        m_Model = _model;
        
        m_Location      = nil;
        m_arrSearchRes  = nil;
        m_loadingThread = nil;
        
        //waitLoadingController = nil;
        flipcontroller  = nil;
        
        m_NoResultSearch = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Заголовок
    NSString *strTitle = nil;
    strTitle = [[NSBundle mainBundle] localizedStringForKey:@"CITY_ADD_CONTROLLER_TITLE" value:nil table:@"InfoPlist"];
    if (strTitle == nil)
        strTitle = [NSString stringWithFormat:@"Not found for key=%@ in localized table", @"CITY_ADD_CONTROLLER_TITLE"];
    
    self.title = strTitle;
    
    UITextField *text = (UITextField *)[m_cellInputFindLoaction viewWithTag:1];
    if (text)
        text.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    m_Model.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actSearchBut:(id)sender
{
    m_arrSearchRes = nil;
    
    // Завершаем ввод в текстовое поле, если есть
    UITextField *text = (UITextField *)[m_cellInputFindLoaction viewWithTag:1];
    if (text)
    {
        if ([text isFirstResponder] == YES)
            [text resignFirstResponder];
        m_Location = text.text;
    }
    
    /*SWWaitProgressController *progressController = [[SWWaitProgressController alloc] init];
    waitLoadingController = progressController;
    waitLoadingController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController: waitLoadingController animated:YES completion:nil];*/
    
    m_NoResultSearch = false;
    
    flipcontroller = [[WSFlipsideViewController alloc] initWithNibName:@"WSFlipsideViewController" bundle:nil];
    flipcontroller.delegate = self;
    flipcontroller.modalTransitionStyle = UIModalTransitionStyleCoverVertical; //UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:flipcontroller animated:YES completion: ^{[self FlipsideViewAppear];} ];
    
}

- (void) FlipsideViewAppear
{
    // Запуск поиска города в базе данных
    m_loadingThread = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(threadParallelProc:)
                                        object:(SWCityAddController*)self];
    [m_loadingThread start];
}

/*
    Поток чтения данных в модель
*/
- (void) threadParallelProc:(SWCityAddController*) controller
{
    BOOL exitNow = NO;
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    // Add the exitNow BOOL to the thread dictionary.
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
    
    [controller->m_Model loadLocations: controller->m_Location];
    
    while (!exitNow)
    {
        // Run the run loop but timeout immediately if the input source isn't waiting to fire.
        [runLoop runUntilDate:[NSDate date]];
        
        // Check to see if an input source handler changed the exitNow value.
        exitNow = [[threadDict valueForKey:@"ThreadShouldExitNow"] boolValue];
    }
}

- (void) LoadingRequestExpectLength: (WSModel*)model  ExpectLength : (long)ExpectLength
{
    [flipcontroller setMaxLength:ExpectLength];
}

- (void) LoadingRequestGetBytes: (WSModel*)model  GetBytes : (long)getBytes
{
    [flipcontroller setCurPos:getBytes];
}

- (void) LoadingRequestDidFinish:(WSModel*)model RequestType: (NSInteger)reqType WithError:(NSError *)error
{
    // Останавливаем поток
    [[m_loadingThread threadDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"ThreadShouldExitNow"];
    
    //NSLog(@"LoadingRequestDidFinish:");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
    else
    {
        m_arrSearchRes = [[NSArray alloc] initWithArray: m_Model.m_LastSearchLocation];
        if ([m_arrSearchRes count] == 0) {
            m_NoResultSearch = true;
        }
        
        [m_TabView reloadData];
    }
}

#pragma mark WSFlipsideViewControllerDelegate Method

- (void)flipsideViewControllerDidFinish:(WSFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

#pragma mark UITableViewDelegate Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    switch (indexPath.row)
    {
        case 0:
            height = 100;
            break;
        case 1:
            height = 44;
            break;
        default:
        {
            if (m_NoResultSearch)
            {
                height =  self.view.bounds.size.height - (100 + 44);
                
            }
            else
            {
                height = 50;
            }
        }
    }
    
    return height;
}

- (void)
tableView:(UITableView *)tV didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_NoResultSearch == false)
    {
        sCity *location = [m_arrSearchRes objectAtIndex:indexPath.row-2];
        [m_Model addFaivoriteLocations: location];
        
        WSAppDelegate *app = (WSAppDelegate*)[[UIApplication sharedApplication] delegate];
        [app.m_SWNavController popViewControllerAnimated:YES];
    }
    
    [tV deselectRowAtIndexPath:indexPath animated: YES];
}

/*- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [m_Model getCountCity])
    {
        return UITableViewCellEditingStyleInsert;
    }
    
    return UITableViewCellEditingStyleDelete;
}*/

#pragma mark UITableViewDataSource Method

-(NSInteger)tableView:(UITableView *)tV numberOfRowsInSection:(NSInteger)section
{
    NSInteger nNumRows = 2;
    
    if (m_NoResultSearch)
        nNumRows += 1;
    else
    {
        if (m_arrSearchRes)
            nNumRows += [m_arrSearchRes count];
    }
    
    return nNumRows;
}

- (UITableViewCell *)tableView:(UITableView *)tV cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    static NSString *reuseCellResult = @"SWCityResultSearchCell";
    
    switch (indexPath.row)
    {
        case 0:
            cell = m_cellInputFindLoaction;
            break;
        case 1:
            cell = m_cellButtonSearch;
            break;
        default:
        {
            if (m_NoResultSearch)
            {
                // Ни одного результат найдено не было
                cell = m_cellResult;
                UILabel *label = (UILabel *)[m_cellResult viewWithTag:1];
                if (label)
                {
                    NSString *str = nil;
                    str = [[NSBundle mainBundle] localizedStringForKey:@"CITY_ADD_CONTROLLER_MSG_NOT_FIND" value:nil table:@"InfoPlist"];
                    
                    assert(str);
                    
                    label.text = str;
                }
            }
            else
            {
                cell = [tV dequeueReusableCellWithIdentifier: reuseCellResult];
                if (nil == cell)
                {
                    /*NSArray *nib = [[NSBundle mainBundle] loadNibNamed:reuseCellResult owner:self options:nil];
                
                     NSEnumerator *nibEnumerator = [nib objectEnumerator];
                     SWCityResultSearchCell *customCell= nil;
                     NSObject* nibItem = nil;
                
                     while ( (nibItem = [nibEnumerator nextObject]) != nil) {
                    
                        if ( [nibItem isKindOfClass: [SWCityResultSearchCell class]]) {
                            customCell = (SWCityResultSearchCell*) nibItem;
                        
                            if ([customCell.reuseIdentifier isEqualToString: reuseCellResult]) {
                                break; // we have a winner
                            }
                        }
                     }
                
                     cell = customCell;
                     //cell = [nib objectAtIndex:0];
                     */
                    sCity *location = [m_arrSearchRes objectAtIndex:indexPath.row-2];
                
                    SWCityResultSearchCell *customCell= nil;
                    customCell = [[SWCityResultSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseCellResult WithLocation:location];
                
                    cell = customCell;
                }
                else
                {
                    sCity *location = [m_arrSearchRes objectAtIndex:indexPath.row-2];
                    [(SWCityResultSearchCell*)cell setLocation: location];
                }
            }
        }
    }
    return cell;
}

/*- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        //[tableViewModel DeleteCityByIndex: indexPath.row];
        //[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}*/

#pragma mark UITextFieldDelegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
