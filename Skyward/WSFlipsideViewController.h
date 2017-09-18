//
//  WSFlipsideViewController.h
//  Skyward
//
//  Created by Сергей Швакель on 11.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSFlipsideViewController;

@protocol WSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(WSFlipsideViewController *)controller;
@end

/*
 Контроллер отображения процесса загрузки данных, обновления данных.
*/
@interface WSFlipsideViewController : UIViewController
{
    long m_MaxLength;
}
@property (weak, nonatomic) id <WSFlipsideViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIProgressView *m_Progress;
@property (strong, nonatomic) IBOutlet UILabel *m_LoadingLab;

- (IBAction)done:(id)sender;

- (void) setMaxLength: (long)maxLength;
- (void) setCurPos: (long)pos;

@end
