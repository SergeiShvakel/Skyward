//
//  WSCityWeathCellViewContext.m
//  Skyward
//
//  Created by Сергей Швакель on 29.05.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "WSCityWeathCellViewContext.h"
#import <CoreText/CTFont.h>

@implementation WSCityWeathCellViewContext

- (id)initWithFrame:(CGRect)frame cell:(WSCoreCell*)cell
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _cell = cell;
        
        m_layStat = nil;
        m_pathArrow = nil;
    }
    return self;
}

- (void) dealloc
{
    if (m_layStat != nil) CGLayerRelease(m_layStat);
    if (m_pathArrow != nil) CGPathRelease(m_pathArrow);
}

- (void) makePathArrow: (CGRect) inRect WindDir: (NSInteger) nWinDir
{
    if (m_pathArrow != nil) CGPathRelease(m_pathArrow);
    
    CGMutablePathRef _path;
    _path = CGPathCreateMutable();
    
    /*CGFloat _points [] = {
        40.0, 90.0,
        40.0, 40.0,
        20.0, 40.0,
        50.0, 10.0,
        80.0, 40.0,
        60.0, 40.0,
        60.0, 90.0
    };*/
    CGFloat _points [] = {
        45.0, 90.0,
        45.0, 35.0,
        25.0, 40.0,
        50.0, 10.0,
        75.0, 40.0,
        55.0, 35.0,
        55.0, 90.0
    };
    CGPoint rotaitpoint = CGPointMake(50.0, 50.0);
    
    int nCountP = sizeof(_points)/sizeof(CGFloat)/2;
    
    CGPathMoveToPoint (_path, NULL, _points[0], _points[1]);
    for (int i = 1; i<nCountP; i++)
    {
        CGPathAddLineToPoint(_path, NULL, _points[i*2], _points[i*2+1]);
    }
    CGPathCloseSubpath(_path);
    
    nWinDir = nWinDir - 180;
    CGFloat fWinDirRadians = 0.0;
    fWinDirRadians = (CGFloat)nWinDir/180.0*M_PI;
    
    CGAffineTransform _transform;
    
    CGPathRef _path1;
    // Смещаем к точке поворота
    _transform = CGAffineTransformMakeTranslation (-rotaitpoint.x, -rotaitpoint.y);
    _path1 = CGPathCreateCopyByTransformingPath(_path, &_transform);
    
    m_pathArrow = CGPathCreateCopy (_path1);
    CGPathRelease(_path1);
    
    // Выполняем поворот
    _transform = CGAffineTransformMakeRotation (fWinDirRadians);
    _path1 = CGPathCreateCopyByTransformingPath(m_pathArrow, &_transform);
    
    CGPathRelease(m_pathArrow);
    m_pathArrow = CGPathCreateCopy (_path1);
    CGPathRelease(_path1);
    
    // Смещаем к начальной точке
    _transform = CGAffineTransformMakeTranslation (rotaitpoint.x, rotaitpoint.y);
    _path1 = CGPathCreateCopyByTransformingPath(m_pathArrow, &_transform);
    
    CGPathRelease(m_pathArrow);
    m_pathArrow = CGPathCreateCopy (_path1);
    CGPathRelease(_path1);
    
    // Масштабируем фигуру
    CGFloat sc = 0.0;
    sc = inRect.size.width <= inRect.size.height ? inRect.size.width/100 : inRect.size.height/100;
    
    _transform = CGAffineTransformMakeScale (sc, sc);
    _path1 = CGPathCreateCopyByTransformingPath(m_pathArrow, &_transform);
    
    CGPathRelease(m_pathArrow);
    m_pathArrow = CGPathCreateCopy (_path1);
    CGPathRelease(_path1);
    
    // Смещаем в нужную позицию
    _transform = CGAffineTransformMakeTranslation (inRect.origin.x, inRect.origin.y);
    _path1 = CGPathCreateCopyByTransformingPath(m_pathArrow, &_transform);
    
    CGPathRelease(m_pathArrow);
    m_pathArrow = CGPathCreateCopy (_path1);
    CGPathRelease(_path1);
    
    CGPathRelease(_path);
}

- (void) makeLayStat: (CGContextRef) context width: (CGFloat)width height: (CGFloat)height
{
    if (m_layStat != nil) CGLayerRelease(m_layStat);
    
    CGSize laySize = CGSizeMake(width, height);
    m_layStat = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_layStat);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();//CGBitmapContextGetColorSpace (context);
    CGFloat colorComp[4];
    colorComp[0] = 190.0/255;
    colorComp[1] = 190.0/255;
    colorComp[2] = 190.0/255;
    colorComp[3] = 0.7;
    
    CGColorRef color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetFillColorWithColor (layContext, color);
    
    CGContextFillRect(layContext, CGRectMake(0, 0, width, height));
    CGColorRelease(color);
    
    colorComp[0] = 255.0/255;
    colorComp[1] = 255.0/255;
    colorComp[2] = 255.0/255;
    colorComp[3] = 1;
    
    //CGColorRef color;
    color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetStrokeColorWithColor (layContext, color);
    CGContextSetFillColorWithColor (layContext, color);
    
    CGFloat x = 0.0, y = 0.0;
    x = width/2+1;
    y = 5;
    CGContextMoveToPoint(layContext, x, y);
    y = height-5;
    CGContextAddLineToPoint(layContext, x, y);
    CGContextClosePath(layContext);
    
    CGContextSetLineWidth(layContext, 0.5);
    CGContextDrawPath(layContext, kCGPathStroke);
    
    x = 5;
    y = height/3;
    CGContextMoveToPoint(layContext, x, y);
    x = width - 5;
    CGContextAddLineToPoint(layContext, x, y);
    CGContextClosePath(layContext);
    CGContextDrawPath(layContext, kCGPathStroke);
    
    x = 5;
    y = height/3*2;
    CGContextMoveToPoint(layContext, x, y);
    x = width - 5;
    CGContextAddLineToPoint(layContext, x, y);
    CGContextClosePath(layContext);
    CGContextDrawPath(layContext, kCGPathStroke);
    
    CGColorRelease(color);
    
    CGFloat fAllignTop = 5.0, fAllignBot = 5.0;
    CGFloat fhCell = (height/3 - 2) - fAllignTop - fAllignBot;
    CGFloat fwCell = width/2-2;
    
    CGFloat colorWhite[4] = {1,1,1,1};
    NSString *fontName = @"Helvetica";
    CGFontRef fontRef = nil;
    
    NSString *tempString = nil;
    unichar *strBuff = nil;
    void *pGlyphsBuff = nil;
    CGGlyph *glyphs = nil;
    CTFontRef tfontref = nil;
    
    CGFloat fFontSize = 20;
        
    color = CGColorCreate(colorSpaceRef, colorWhite);
    CGContextSetFillColorWithColor (layContext, color);
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(layContext, fontRef);
    CGContextSetFontSize (layContext, fFontSize);
    
    CGContextSetCharacterSpacing (layContext, 0.8);
    CGContextSetTextDrawingMode (layContext, kCGTextFill);
    
    tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                      fFontSize,
                                      nil);
    
    // Отображаем текст - вложность
    tempString = [NSString stringWithFormat:@"%d%%", _cell.data.nHumidity];
        
    strBuff = calloc([tempString length], sizeof(unichar));
    NSRange range;
    range.location=0;
    range.length=[tempString length];
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc([tempString length], sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  [tempString length]);
    // вычисляем позицию текста
    CGFloat tXPos = 0.0, tYPos = 0.0;
    tXPos = width/2 + 15;
    tYPos = (fhCell+fAllignTop+fAllignBot+1)-(fhCell+fAllignTop+fAllignBot+1)/2+(fFontSize/2);
    
    CGContextSaveGState(layContext);
    CGContextTranslateCTM(layContext, 0, tYPos);
    CGContextScaleCTM(layContext, 1, -1);
    
    //CGContextShowGlyphsAtPoint (layContext, tXPos, 0, glyphs, [tempString length]);
    CGPoint Lposition;
    Lposition.x = tXPos;
    Lposition.y = 0;
    
    CGContextShowGlyphsAtPositions (layContext, glyphs, &Lposition,  [tempString length]);
    
    CGContextRestoreGState(layContext);
    
    CGColorRelease(color);
    
    free(pGlyphsBuff);
    free(strBuff);
    
    // Отображаем текст - скорость ветра
    CGFloat fWindSpeed = 0.0;
    fWindSpeed = (CGFloat)_cell.data.nWindSpeedKmph*1000.0/3600.0;
    fWindSpeed = floorf(fWindSpeed+0.5);
    tempString = [NSString stringWithFormat:@"%.0fm/s", fWindSpeed];
    
    strBuff = calloc([tempString length], sizeof(unichar));
    range.location=0;
    range.length=[tempString length];
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc([tempString length], sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  [tempString length]);
    // вычисляем позицию текста
    tXPos = 0.0, tYPos = 0.0;
    tXPos = width/2 + 15;
    tYPos = (fhCell+fAllignTop+fAllignBot+1)*2-(fhCell+fAllignTop+fAllignBot+1)/2+(fFontSize/2);
    
    CGContextSaveGState(layContext);
    CGContextTranslateCTM(layContext, 0, tYPos);
    CGContextScaleCTM(layContext, 1, -1);
    
    Lposition.x = tXPos;
    Lposition.y = 0;
    
    //CGContextShowGlyphsAtPoint (layContext, tXPos, 0, glyphs, [tempString length]);
    CGContextShowGlyphsAtPositions (layContext, glyphs, &Lposition, [tempString length]);
    
    CGContextRestoreGState(layContext);
    
    free(pGlyphsBuff);
    free(strBuff);    
    
    CGFontRelease(fontRef);
    
    // Рисуем направление ветра
    tXPos = 0.0, tYPos = 0.0;
    tXPos = width/2 + 15;
    tYPos = (fhCell+fAllignTop+fAllignBot+1)*2+fAllignTop;
    
    [self makePathArrow: CGRectMake(tXPos, tYPos, fwCell, fhCell) WindDir:_cell.data.nWindDir];
    
    CGContextAddPath(layContext, m_pathArrow);
    
    color = CGColorCreate(colorSpaceRef, colorWhite);
    /*CGContextSetStrokeColorWithColor (layContext,
                                      color);*/
    CGContextSetFillColorWithColor (layContext,
                                    color);
    CGContextDrawPath (layContext, kCGPathFillStroke);
    
    CGColorRelease(color);
    
    CGColorSpaceRelease(colorSpaceRef);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef drawContext = UIGraphicsGetCurrentContext();
    
    CGRect CellRect = _cell.contentView.bounds;
    
    CGFloat w, h;
    w = CellRect.size.width;
    h = CellRect.size.height;
    
    // Размеры "клеток"
    CGFloat fWidth1 = w/8;
    CGFloat fHeight1 = h/14;
    
    // Выполняем заливку фона
    CGContextSetRGBFillColor (drawContext, 146.0/255, 174.0/255, 231.0/255, 1);
    CGContextFillRect(drawContext, CGRectMake(0, 0, w, h));
    
    // Заливка верхней части
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();//CGBitmapContextGetColorSpace (context);
    CGFloat colorComp[4];
    colorComp[0] = 190.0/255;
    colorComp[1] = 190.0/255;
    colorComp[2] = 190.0/255;
    colorComp[3] = 0.7;
    
    CGColorRef color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetFillColorWithColor (drawContext, color);
    
    CGContextFillRect(drawContext, CGRectMake(0, 0, w, 3*fHeight1));
    CGColorRelease(color);
    
    // Верхнее 1/3 - Город, дата, время
    //CGFloat fH = h/3;
    CGFloat fYpos = 0.0/*, fHFont = 0.0*/; //
    //CGFloat fDelta = fH/5;
    
    // Местоположение
    /*fHFont = fDelta;
    fYpos = fDelta + fHFont;
    
    CGContextSaveGState(drawContext);
    CGContextTranslateCTM(drawContext, 0, fYpos);
    CGContextScaleCTM(drawContext, 1, -1);
    
    CGContextSelectFont (drawContext,
                         "Helvetica-Bold",
                         fHFont,
                         kCGEncodingFontSpecific);
    CGContextSetCharacterSpacing (drawContext, 2);
    CGContextSetTextDrawingMode (drawContext, kCGTextFill);
    
    CGContextSetRGBFillColor (drawContext, 1, 1, 1, 1);
    //CGContextSetRGBStrokeColor (drawContext, 0, 0, 1, 1);
    
    CGContextShowTextAtPoint (drawContext, 10, 0, [_cell.data.CurrentCity cStringUsingEncoding: NSUnicodeStringEncoding], [_cell.data.CurrentCity length]);
    CGContextRestoreGState(drawContext);*/
    
    CGFloat fFontSize = 30;
    CGFloat fSpacing = 0.6;
    
    NSString *fontName = @"Helvetica";
    CGFontRef fontRef = nil;
    
    NSString *tempString = nil;
    unichar *strBuff = nil;
    void *pGlyphsBuff = nil;
    CGGlyph *glyphs = nil;
    CTFontRef tfontref = nil;
    NSRange range;
    
    tempString = [NSString stringWithFormat:@"%@", _cell.data.CurrentCity];
    
    strBuff = calloc([tempString length], sizeof(unichar));
    range.location=0;
    range.length=[tempString length];
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc([tempString length], sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    // определяем буквы для печати и размер шрифта для печати текста
    BOOL bCalcOk = FALSE;
    
    do {
        tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                          fFontSize,
                                          nil);        
        CTFontGetGlyphsForCharacters (tfontref,
                                      strBuff,
                                      glyphs,
                                      [tempString length]);
        double dAdvances = 0.0;
        dAdvances = CTFontGetAdvancesForGlyphs (tfontref,
                                                kCTFontDefaultOrientation,
                                                glyphs,
                                                nil,
                                                [tempString length]);
        if ((dAdvances+[tempString length]*fSpacing < w-20) || fFontSize==20 )
            bCalcOk = TRUE;
        else
            fFontSize--;
        
    } while (!bCalcOk);
    
    // вычисляем позицию текста
    fYpos = 10;
    CGFloat tXPos = 0.0, tYPos = 0.0;
    tXPos = 10;
    tYPos = fYpos;
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(drawContext, fontRef);
    CGContextSetFontSize (drawContext, fFontSize);
    
    CGContextSetCharacterSpacing (drawContext, fSpacing);
    CGContextSetTextDrawingMode (drawContext, kCGTextFill);
    
    CGContextSetRGBFillColor (drawContext, 1, 1, 1, 1);
    
    CGContextSaveGState(drawContext);
    CGContextTranslateCTM(drawContext, 0, tYPos+fFontSize);
    CGContextScaleCTM(drawContext, 1, -1);
    
    CGPoint Lposition;
    Lposition.x = tXPos;
    Lposition.y = 0;
    
    //CGContextShowGlyphsAtPoint (drawContext, tXPos, 0, glyphs, [tempString length]);
    CGContextShowGlyphsAtPositions (drawContext, glyphs, &Lposition, [tempString length]);
    
    CGContextRestoreGState(drawContext);
    
    free(pGlyphsBuff);
    free(strBuff);
    
    CGFontRelease(fontRef);
    
    // Время запроса
    //fHFont = fH/8;
    //fYpos = fDelta*3 + fHFont + 2;
    
    /*CGContextSaveGState(drawContext);
    CGContextTranslateCTM(drawContext, 0, fYpos);
    CGContextScaleCTM(drawContext, 1, -1);
    
    CGContextSelectFont (drawContext,
                         "Helvetica",
                         fHFont,
                         kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (drawContext, 2);
    CGContextSetTextDrawingMode (drawContext, kCGTextFillStroke);
    
    CGContextSetRGBFillColor (drawContext, 0, 1, 0, .5);
    CGContextSetRGBStrokeColor (drawContext, 0, 0, 1, 1);
    
    CGContextShowTextAtPoint (drawContext, 15, 0, [_cell.data.CurrentTime cStringUsingEncoding: NSASCIIStringEncoding], [_cell.data.CurrentTime length]);
    CGContextRestoreGState(drawContext);*/
    
    // вычисляем позицию текста
    fYpos += fFontSize;
    fYpos += 2;
    tXPos = 10;
    tYPos = fYpos;
    
    fFontSize = 15;
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(drawContext, fontRef);
    CGContextSetFontSize (drawContext, fFontSize);
    
    CGContextSetCharacterSpacing (drawContext, fSpacing);
    CGContextSetTextDrawingMode (drawContext, kCGTextFill);
    
    CGContextSetRGBFillColor (drawContext, 1, 1, 1, 1);
    
    tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                      fFontSize,
                                      nil);
    
    tempString = [NSString stringWithFormat:@"%@", _cell.data.CurrentTime];
    
    strBuff = calloc([tempString length], sizeof(unichar));
    range.location=0;
    range.length=[tempString length];
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc([tempString length], sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  [tempString length]);
    
    CGContextSaveGState(drawContext);
    CGContextTranslateCTM(drawContext, 0, tYPos+fFontSize);
    CGContextScaleCTM(drawContext, 1, -1);
    
    Lposition.x = tXPos;
    Lposition.y = 0;
    
    //CGContextShowGlyphsAtPoint (drawContext, tXPos, 0, glyphs, [tempString length]);
    CGContextShowGlyphsAtPositions (drawContext, glyphs, &Lposition, [tempString length]);
    
    CGContextRestoreGState(drawContext);
    
    free(pGlyphsBuff);
    free(strBuff);
    
    CGFontRelease(fontRef);
    
    CGRect wStatRect;
    wStatRect.origin.x = fWidth1*4;
    wStatRect.origin.y = fHeight1*7;
    wStatRect.size.height = fHeight1*5, wStatRect.size.width = fWidth1*4;
    [self makeLayStat:drawContext width:wStatRect.size.width height:wStatRect.size.height];
    
    CGContextDrawLayerAtPoint (drawContext, wStatRect.origin, m_layStat);    
}

@end
