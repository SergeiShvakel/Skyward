//
//  wsElemTherm.h
//  Skyward
//
//  Created by Сергей Швакель on 30.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wsElemTherm : UIView
{
    NSInteger Temperature;
    
    CGFloat m_pixelsWide;   // Текущий размер картинки
    CGFloat m_pixelsHigh;
    
    CGFloat m_InitWid, m_InitHih;
    CGPoint *m_points;  // контрольные точки рисования
    CGFloat m_nRadius1;     // радиус маленькой окружности = 7;
    CGFloat m_nRadius2;     // радиус большой окружности = (int)m_nRadius1*1.5;
    
    CGAffineTransform m_transform;  // матрица трансформации
    CGFloat m_sx, m_sy;             // масштаб
    
    /* Элемент Термометр - контекст картинка */
    CGContextRef bmpElemTherm;
    
    /*
        Path'ы для рисования термометра.
    */
    CGPathRef m_thermpath1; // уровень температуры
    CGPathRef m_thermpath2; // термометр полный с закругленными краями
    CGPathRef m_path3;      // овал текущего уровня температуры
    
    CGMutablePathRef m_grad;
    
    // 1 Слой картинки - термометр с указанием температуры
    CGLayerRef m_layTherm1;
    // 2 Слой картинки - термометр полностью
    CGLayerRef m_layTherm2;
    CGLayerRef m_layTherm3;
    CGLayerRef m_layTherm3_2;   // овал уровня температуры
    CGLayerRef m_lay4;          // слой фона
}

- (id) initWithFrame:(CGRect)frame;
- (void) dealloc;

@property (nonatomic) NSInteger Temperature;

@end
