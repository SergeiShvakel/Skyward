//
//  WSControllerTabView.m
//  Skyward
//
//  Created by Сергей Швакель on 20.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSControllerTabView.h"
#import "WSAppDelegate.h"
#import "WSCityWeathCell.h"

@interface WSControllerTabView ()

@end

@implementation WSControllerTabView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil model: (WSModel*) _model
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
        
        m_Model = _model;
        m_Model.delegate = self;
        
        m_IDLocation = m_Model.m_lastIDLocation;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.allowsSelection = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([m_Model isNeedUpdateWeathForecast: m_IDLocation])
        [self refreshWeath];
    
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshWeath
{
    flipcontroller = [[WSFlipsideViewController alloc] initWithNibName:@"WSFlipsideViewController" bundle:nil];
    flipcontroller.delegate = self;
    flipcontroller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:flipcontroller animated:YES completion: ^{[self FlipsideViewAppear];} ];
}

- (void) FlipsideViewAppear
{
    // Запуск поиска города в базе данных
    m_loadingThread = [[NSThread alloc] initWithTarget:self
                                              selector:@selector(threadParallelProc:)
                                              object:(WSControllerTabView*)self];
    [m_loadingThread start];
}

/*
    Поток чтения данных в модель
*/
- (void) threadParallelProc:(WSControllerTabView*) controller
{
    BOOL exitNow = NO;
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    
    // Add the exitNow BOOL to the thread dictionary.
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
    [threadDict setValue:[NSNumber numberWithBool:exitNow] forKey:@"ThreadShouldExitNow"];
    
    [controller->m_Model loadWeathForecast: controller->m_IDLocation];
    
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

- (void) LoadingRequestDidFinish:(WSModel*)model RequestType:(NSInteger)reqType WithError:(NSError *)error
{
    // Останавливаем поток
    [[m_loadingThread threadDictionary] setValue:[NSNumber numberWithBool:YES] forKey:@"ThreadShouldExitNow"];
    
    //NSLog(@"LoadingRequestDidFinish:");
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

/*
    Метод реагирует на событие остановки параллельного потока
*/
- (void) aThreadHasFinished:(id)object
{
    //WSModel *model = (WSModel *)(object);
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self.tableView reloadData];}
     ];
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    NSInteger rowCount = 1;
    
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CityWeathCell";
    
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil)
            {
                cell = [[WSCityWeathCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier weathData:m_Model.m_CurrWeather];
            }
            
            WSCityWeathCell *CityWeathCell = (WSCityWeathCell*)cell;
            [CityWeathCell setData:m_Model.m_CurrWeather];
            [CityWeathCell setController:self];
            
            break;
        }
        case 1:
            break;
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 1. Получаем общую высоту таблицы
    CGRect rect = tableView.frame,
           rect2 = tableView.bounds;
    CGSize size = tableView.contentSize;
    
    UIEdgeInsets sizeEdge = tableView.contentInset;
    
    // 2. Определяем сколько будем отображать городов
    
    // 3. Вычисляем высоту строки
    CGFloat height = 0.0;
    switch (indexPath.row)
    {
        case 0:
            height = rect.size.height-40;
            break;
        case 1:
            height = 362;
            break;
    }
    
    //height = rect.size.height;
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark WSFlipsideViewControllerDelegate Method

- (void)flipsideViewControllerDidFinish:(WSFlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
    return;
}

@end
