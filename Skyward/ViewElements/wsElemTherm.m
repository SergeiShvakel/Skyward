//
//  wsElemTherm.m
//  Skyward
//
//  Created by Сергей Швакель on 30.04.13.
//  Copyright (c) 2013 Сергей Швакель. All rights reserved.
//

#import "wsElemTherm.h"
#import <CoreText/CTFont.h>

@implementation wsElemTherm

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initClass];
        
        m_pixelsWide = frame.size.width;
        m_pixelsHigh = frame.size.height;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self)
    {
        [self initClass];
    }
    return self;
}

- (void) initClass
{
    [self setTranslatesAutoresizingMaskIntoConstraints: YES];
    self.alpha = 1;
    self.opaque = NO;
    self.backgroundColor = nil;
    
    bmpElemTherm = nil;
    
    m_pixelsWide = 100;
    m_pixelsHigh = 145;
    
    m_InitWid = 100;
    m_InitHih = 145;
    
    Temperature = 0;
    
    m_points = calloc(2, sizeof(CGPoint));
    m_points[0] = CGPointMake(15, 105);
    m_points[1] = CGPointMake(15, 15);
    
    m_nRadius1 = 10.0;
    m_nRadius2 = m_nRadius1*1.5;
    
    m_sx = m_sy = 1.0;
    
    m_lay4 = NULL;
}

- (void) dealloc
{
    if (m_thermpath1 != NULL) CGPathRelease(m_thermpath1);
    if (m_thermpath2 != NULL) CGPathRelease(m_thermpath2);
    if (m_path3 != NULL) CGPathRelease(m_path3);
    
    if (m_grad != NULL) CGPathRelease(m_grad);
    
    if (m_layTherm1 != NULL) CGLayerRelease(m_layTherm1);
    if (m_layTherm2 != NULL) CGLayerRelease(m_layTherm2);
    if (m_layTherm3 != NULL) CGLayerRelease(m_layTherm3);
    if (m_layTherm3_2 != NULL) CGLayerRelease(m_layTherm3_2);
    if (m_lay4 != NULL) CGLayerRelease(m_lay4);
    
    if (bmpElemTherm != NULL)
    {
        void *bitmapData = NULL;
        
        // Удаление графического контекста
        bitmapData = CGBitmapContextGetData(bmpElemTherm);
        CGContextRelease(bmpElemTherm);
        if (bitmapData) free(bitmapData);
    }
    
    free (m_points);
}

- (NSInteger) Temperature
{
    return Temperature;
}

- (void) setTemperature:(NSInteger)_Temperature
{
    Temperature = _Temperature;

    [self setNeedsDisplay];
}

// контуры уровня температуры
- (void) createPath1: (long) nTempCels
{
    CGFloat fH = m_nRadius1/3, fGyp1=0.0, fAng1 = 0.0, fRadius = 0.0;
    fGyp1 = sqrt(pow(m_nRadius1,2) + pow(fH,2));
    fAng1 = asin(fH/fGyp1);
    fRadius = fGyp1/2/sin(fAng1);
    
    CGFloat fDeltaRad = 0.0;
    fDeltaRad = acos(m_nRadius1/fRadius);
    
    int nTempZero = 30;
    CGFloat fHigTemp = (nTempCels+nTempZero)*((m_points[0].y-m_points[1].y-10.0)/70);
    
    CGMutablePathRef _thermpath;
    
    _thermpath = CGPathCreateMutable();
    
    CGPathMoveToPoint (_thermpath, NULL, m_points[0].x, m_points[0].y);
    CGPathAddLineToPoint(_thermpath, NULL, m_points[0].x, m_points[0].y - fHigTemp);
    
    CGPathAddArc (_thermpath,
                  NULL,
                  m_points[0].x+m_nRadius1,
                  m_points[0].y - fHigTemp - (fRadius - fH),
                  fRadius,
                  M_PI-fDeltaRad,
                  fDeltaRad,
                  1);
    
    CGPathAddLineToPoint(_thermpath, NULL, m_points[0].x+m_nRadius1*2, m_points[0].y);
    
    /*CGPathAddArc (_thermpath,
                  NULL,
                  m_points[0].x+m_nRadius1,
                  m_points[0].y-(fRadius - fH),
                  fRadius,
                  fDeltaRad,
                  M_PI-fDeltaRad,
                  0);*/
    
    // Вычисляем высоту
    float fHight = 0.0, fRadian1 = 0.0, fRadian2 = 0.0;
    fHight = sqrt(pow(m_nRadius2,2) - pow(m_nRadius1,2));
    fRadian1 = asin(fHight/m_nRadius2);
    fRadian2 = fRadian1+M_PI;
    
    CGPathAddArc(_thermpath, NULL,
                 m_points[0].x+m_nRadius1,
                 m_points[0].y+fHight,
                 m_nRadius2,
                 -fRadian1,// -0.73,
                 fRadian2, //3.87,
                 0);
    
    
    CGPathCloseSubpath(_thermpath);
    
    if (m_thermpath1 != nil) CGPathRelease(m_thermpath1);
    m_thermpath1 = CGPathCreateCopyByTransformingPath(_thermpath, &m_transform);
}

// контуры самого термометра
- (void) createPath2
{    
    CGMutablePathRef _thermpath;
    
    _thermpath = CGPathCreateMutable();
    
    CGPathMoveToPoint (_thermpath, NULL, m_points[0].x, m_points[0].y);
    CGPathAddLineToPoint(_thermpath, NULL, m_points[1].x, m_points[1].y);
    CGPathAddArcToPoint(_thermpath, NULL,
     m_points[1].x,
     m_points[1].y-m_nRadius1,
     m_points[1].x+m_nRadius1,
     m_points[1].y-m_nRadius1,
     m_nRadius1);
    CGPathAddArcToPoint(_thermpath, NULL,
     m_points[1].x+m_nRadius1*2,
     m_points[1].y-m_nRadius1,
     m_points[1].x+m_nRadius1*2,
     m_points[1].y+m_nRadius1*2,
     m_nRadius1);
    CGPathAddLineToPoint(_thermpath, NULL, m_points[1].x+m_nRadius1*2, m_points[0].y);
    
    // Вычисляем высоту
    float fHight = 0.0, fRadian1 = 0.0, fRadian2 = 0.0;
    fHight = sqrt(pow(m_nRadius2,2) - pow(m_nRadius1,2));
    fRadian1 = asin(fHight/m_nRadius2);
    fRadian2 = fRadian1+M_PI;
    
    CGPathAddArc(_thermpath, NULL,
                  m_points[0].x+m_nRadius1,
                  m_points[0].y+fHight,
                  m_nRadius2,
                  -fRadian1,// -0.73,
                  fRadian2, //3.87,
                  0);     
    CGPathCloseSubpath(_thermpath);
    
    CGFloat fH = m_nRadius1/3;
    
    CGRect ElipsRect;
    
    ElipsRect.origin.x = m_points[1].x+1;
    ElipsRect.origin.y = m_points[1].y - fH;
    ElipsRect.size.height = fH*2;
    ElipsRect.size.width = m_nRadius1*2-1;
    CGPathAddEllipseInRect (_thermpath, NULL, ElipsRect);
    CGPathCloseSubpath(_thermpath);
    
    if (m_thermpath2 != nil) CGPathRelease(m_thermpath2);
    m_thermpath2 = CGPathCreateCopyByTransformingPath(_thermpath, &m_transform);
}

// Элипс текущей температуры
- (void) createPath3:(long) nTempCels
{
    CGMutablePathRef _thermpath;
    
    _thermpath = CGPathCreateMutable();
    
    CGFloat fH = m_nRadius1/3;
    int nTempZero = 30;
    CGFloat nHigTemp = (nTempCels+nTempZero)*((m_points[0].y-m_points[1].y-10.0)/70.0);
    
    CGRect ElipsRect;
    ElipsRect.origin.x = m_points[0].x+1;
    ElipsRect.origin.y = m_points[0].y - nHigTemp - fH;
    ElipsRect.size.height = fH*2;
    ElipsRect.size.width = m_nRadius1*2-1;
    
    CGPathAddEllipseInRect (_thermpath, NULL, ElipsRect);
    
    CGPathCloseSubpath(_thermpath);
    
    if (m_path3 != nil) CGPathRelease(m_path3);
    m_path3 = CGPathCreateCopyByTransformingPath(_thermpath, &m_transform);
}

- (void) createpathgrad
{
    if (m_grad != NULL)
    {
        CGPathRelease(m_grad);
        m_grad = NULL;
    }
    m_grad = CGPathCreateMutable();
    
}

// Создание слоя с градиентной заливкой уровня температуры
static void myCalculateShadingValues (void *info,
                                      const CGFloat *in,
                                      CGFloat *out)
{
    CGFloat v;
    size_t k, components;
    //static const CGFloat c[] = {1, 0, .5, 0 };
    static const int arrColl[] =
    {
        -32, 173, 41, 255,
        -28, 121, 62, 195,
        -24, 58, 41, 255,
        -20, 90, 79, 255,
        -16, 130, 124, 255,
        -12, 40, 108, 255,
        -8, 81, 176, 255,
        -4, 98, 214, 255,
        -2, 146, 255, 232,
        0, 109, 255, 55,
        2, 167, 255, 123,
        4, 222, 255, 125,
        8, 255, 255, 137,
        12, 254, 226, 104,
        16, 253, 186, 87,
        20, 253, 147, 8,
        24, 252, 89, 94,
        28, 251, 33, 45,
        32, 251, 0, 10,
        36, 248, 0, 170
    };
    int N = 0, Ind = -1;
    int nCountPair = sizeof(arrColl)/sizeof(int)/4;
    
    components = (size_t)info;
    
    v = *in;
    CGFloat f = v*70.0 - 30;
    N = v*70.0 - 30;
    
    for (int i = 0; i < nCountPair; i++)
    {
        if (N < arrColl[i*4])
        {
            Ind = i;
            break;
        }
    }
    if (Ind == -1) Ind = nCountPair-1;
    //if (Ind == 0) Ind++;
    
    CGFloat color = 0.0;
    
    for (k = 0; k < components -1; k++)
    {
        if (Ind > 0 && Ind < nCountPair-1)
        {
            CGFloat x1 = 0, y1 = 0, x2 = 0.0, y2 = 0.0;
            x1 = arrColl[(Ind-1)*4];
            x2 = arrColl[Ind*4];
            y1 = arrColl[(Ind-1)*4+k+1];
            y2 = arrColl[Ind*4+k+1];
            
            CGFloat a = 0.0, b = 0.0;
            a = ((CGFloat)(y1-y2))/(x1-x2);
            b = (CGFloat)(y1 - a*x1);
            
            color = (a*f+b)/255;
            *out++ = color;
        }
        else
        {
            color = (CGFloat)arrColl[Ind*4+k+1]/255.0;
            *out++ = color;
        }
    }
    *out++ = 1;
}

CGFunctionRef myGetFunction (CGColorSpaceRef colorspace)
{
    size_t numComponents;
    static const CGFloat input_value_range [2] = { 0, 1 };
    static const CGFloat output_value_ranges [8] = { 0, 1, 0, 1, 0, 1, 0, 1 };
    static const CGFunctionCallbacks callbacks = {  0,
                                                    &myCalculateShadingValues,
                                                    NULL };
    
    numComponents = 1 + CGColorSpaceGetNumberOfComponents (colorspace);
    return CGFunctionCreate ((void *) numComponents,
                             1,
                             input_value_range,
                             numComponents,
                             output_value_ranges,
                             &callbacks);
}

- (void) createLayTherm1: (CGContextRef) context
{
    if (m_layTherm1 != NULL)
    {
        CGLayerRelease(m_layTherm1);
        m_layTherm1 = NULL;
    }
    
    long nTemper = Temperature;
    if (nTemper > 40) nTemper = 40;
    else if (nTemper < -30) nTemper = -30;
    
    [self createPath1: nTemper];
    
    CGSize laySize = CGSizeMake(m_pixelsWide, m_pixelsHigh);
    m_layTherm1 = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_layTherm1);
    
    CGPoint startPoint, endPoint;
    
    // нижняя точка
    startPoint.x = m_points[0].x + m_nRadius1;
    startPoint.y = m_points[0].y;
    
    endPoint.x = m_points[0].x + m_nRadius1;
    endPoint.y = m_points[1].y+5;
    
    startPoint = CGPointApplyAffineTransform (startPoint, m_transform);
    endPoint = CGPointApplyAffineTransform (endPoint, m_transform);
    
    CGColorSpaceRef colorSpaceRef = CGBitmapContextGetColorSpace (context);
    CGFunctionRef myFunctionObject;
    CGShadingRef myShading;
    
    myFunctionObject = myGetFunction(colorSpaceRef);
    myShading = CGShadingCreateAxial (colorSpaceRef,
                                      startPoint,
                                      endPoint,
                                      myFunctionObject,
                                      true,
                                      false);
    
    CGContextAddPath(layContext, m_thermpath1);
    CGContextClip (layContext);
    
    CGContextDrawShading (layContext, myShading);
    
    CGColorSpaceRelease (colorSpaceRef);
    CGShadingRelease (myShading);
    CGFunctionRelease (myFunctionObject);
    
    //CGContextSetRGBFillColor (layContext, 1, 0, 0, 1);
    //CGContextFillPath(layContext);
}

// слой контуров термометра
- (void) createLayTherm2: (CGContextRef) context
{
    CGSize myShadowOffset = CGSizeMake (5, 10);
    
    if (m_layTherm2 != NULL)
    {
        CGLayerRelease(m_layTherm2);
        m_layTherm2 = NULL;
    }
    
    [self createPath2];
    
    CGSize laySize = CGSizeMake(m_pixelsWide, m_pixelsHigh);
    m_layTherm2 = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_layTherm2);
    
    CGContextSaveGState(layContext);
    // добавление тени
    CGContextSetShadow (layContext, myShadowOffset, 5);
    
    // 1 path - контуры термометра
    CGContextAddPath(layContext, m_thermpath2);
    
    CGColorSpaceRef colorSpaceRef = CGBitmapContextGetColorSpace (context);
    CGFloat colorComp[4] = {1,1,1,1};
    
    CGColorRef color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetStrokeColorWithColor (layContext,
                                      color);
    
    CGContextSetRGBFillColor (layContext, 1, 1, 1, 0.2);
    CGContextDrawPath (layContext, kCGPathFillStroke);
    
    CGColorRelease(color);
    
    // 2 path - разметка термометра
    CGFloat fH = m_nRadius1/3, fGyp1=0.0, fAng1 = 0.0, fRadius = 0.0;
    fGyp1 = sqrt(pow(m_nRadius1,2) + pow(fH,2));
    fAng1 = asin(fH/fGyp1);
    fRadius = fGyp1/2/sin(fAng1);
    
    CGFloat fDeltaRad = 0.0;
    fDeltaRad = acos(m_nRadius1/fRadius);
    
    CGFloat fStep = (m_points[0].y-m_points[1].y-10.0)/70.0;
    
    for (int i = 0; i < 15; i++)
    {
        CGMutablePathRef _thermpath;
        _thermpath = CGPathCreateMutable();
        
        CGFloat fDelta2 = 0.0;
        if (i%2 == 0) fDelta2 = 0.3;
        else fDelta2 = 0.65;
    
        CGPathAddArc (_thermpath,
                      &m_transform,
                      m_points[0].x+m_nRadius1,
                      m_points[0].y - i*5*fStep - (fRadius - fH),
                      fRadius,
                      M_PI-fDeltaRad-fDelta2,
                      fDeltaRad,
                      1);
        CGContextAddPath(layContext, _thermpath);
    }
    CGFloat colorComp2[4] = {0.1,0.1,0.1,1};
    
    color = CGColorCreate(colorSpaceRef, colorComp2);
    CGContextSetStrokeColorWithColor (layContext,
                                      color);
    CGContextDrawPath (layContext, kCGPathStroke);
    CGColorRelease(color);
    
    CGContextRestoreGState(layContext);
}

// Слой температура
- (void) createLayTherm3: (CGContextRef) context
{
    if (m_layTherm3 != NULL)
    {
        CGLayerRelease(m_layTherm3);
        m_layTherm3 = NULL;
    }
    
    CGSize laySize = CGSizeMake(m_pixelsWide, m_pixelsHigh);
    m_layTherm3 = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_layTherm3);
    
    CGFloat colorBlack[4] = {0,0,0,1};
    CGFloat colorWhite[4] = {1,1,1,1};
    CGColorRef color = nil;
    
    NSString *fontName = @"Helvetica";
    CGFontRef fontRef = nil;
    
    NSString *tempString = nil;
    unichar *strBuff = nil;
    void *pGlyphsBuff = nil;
    CGGlyph *glyphs = nil;
    CTFontRef tfontref = nil;
    
    int nTempZero = 30;
    CGFloat fHigTemp = 0.0;
    
    CGFloat fFontSize = 0.0;
    
    CGColorSpaceRef colorSpaceRef = CGBitmapContextGetColorSpace (context);
    
    CGFloat fSpacing = 1.5;
    
    // 1. Отображаем текст уровень 0
    CGContextSaveGState(layContext);
    
    fFontSize = 10;
    
    color =  CGColorCreate(colorSpaceRef, colorBlack);
    CGContextSetFillColorWithColor (layContext, color);
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(layContext, fontRef);
    CGContextSetFontSize (layContext, fFontSize);
    
    CGContextSetCharacterSpacing (layContext, 0.8);
    CGContextSetTextDrawingMode (layContext, kCGTextFill);
    
    tempString = @"0º";
    NSUInteger nGlyphsCount = 0;
    nGlyphsCount = [tempString length];

    strBuff = calloc(nGlyphsCount, sizeof(unichar));
    NSRange range;
    range.location=0;
    range.length=nGlyphsCount;
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc(nGlyphsCount, sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                      fFontSize,
                                      &m_transform);
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  nGlyphsCount);
    if (strBuff) free(strBuff);
    
    // вычисляем позицию текста
    fHigTemp = (nTempZero)*((m_points[0].y-m_points[1].y-10.0)/70.0);
    
    CGFloat fYpos = 0.0;
    fYpos = (m_points[0].y - fHigTemp + fFontSize/2)*m_sy;
    CGContextTranslateCTM(layContext, 0, /*m_points[0].y*/fYpos);
    CGContextScaleCTM(layContext, m_sx, -m_sy);
    
    //CGPoint Lposition;
    //Lposition.x = m_points[0].x+m_nRadius1*2+1;
    //Lposition.y = /*fYpos*/0;
    
    // Определяем массив точек для рисования букв
    CGPoint *positionsGlyph = NULL;
    CGRect *boundingRects = NULL;
    
    positionsGlyph = calloc(nGlyphsCount, sizeof(CGPoint));
    boundingRects = calloc(nGlyphsCount, sizeof(CGRect));
    
    CTFontGetBoundingRectsForGlyphs (tfontref,
                                     kCTFontDefaultOrientation,
                                     glyphs,
                                     boundingRects,
                                     nGlyphsCount);
    
    CGFloat fOffsets = 0;
    for (int i = 0; i < nGlyphsCount; i++)
    {
        positionsGlyph[i].x = m_points[0].x+m_nRadius1*2+1+fOffsets;
        positionsGlyph[i].y = 0;
        
        fOffsets += boundingRects[i].size.width + fSpacing;
    }
    
    CGContextShowGlyphsAtPositions (layContext, glyphs, positionsGlyph, nGlyphsCount);
    
    free(boundingRects);
    free(positionsGlyph);
    free(pGlyphsBuff);
    
    CGFontRelease(fontRef);
    CGColorRelease(color);
    CGContextRestoreGState(layContext);
    
    
    // 2. Отображаем текст текущей температуры
    CGContextSaveGState(layContext);
    
    fFontSize = 28;
    
    // добавление текста температуры
    //CGContextSetShadow (layContext, myShadowOffset, 5);
    
    color = CGColorCreate(colorSpaceRef, colorWhite);
    CGContextSetFillColorWithColor (layContext, color);
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(layContext, fontRef);
    CGContextSetFontSize (layContext, fFontSize);
    
    CGContextSetCharacterSpacing (layContext, 0.8);
    CGContextSetTextDrawingMode (layContext, kCGTextFill);
   
    tempString = [NSString stringWithFormat:@"%ldº", Temperature];
    nGlyphsCount = [tempString length];
        
    strBuff = calloc(nGlyphsCount, sizeof(unichar));
    range.location=0;
    range.length=nGlyphsCount;
    [tempString getCharacters:strBuff range:range];
    
    pGlyphsBuff = calloc(nGlyphsCount, sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                      fFontSize,
                                      &m_transform);
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  nGlyphsCount);
    if (strBuff) free(strBuff);
    
    // вычисляем позицию текста
    long nTemper = Temperature;
    if (nTemper > 40) nTemper = 40;
    else if (nTemper < -30) nTemper = -30;
    
    fHigTemp = (nTemper+nTempZero)*((m_points[0].y-m_points[1].y-10.0)/70.0);
    
    fYpos = (m_points[0].y - fHigTemp + fFontSize/2)*m_sy;
    CGContextTranslateCTM(layContext, 0, fYpos);    
    CGContextScaleCTM(layContext, m_sx, -m_sy);
    
    //+CGContextShowGlyphsAtPoint (layContext, m_points[0].x+m_nRadius1*2+10, 0, glyphs, [tempString length]);
    
    // Определяем массив точек для рисования букв
    positionsGlyph = NULL;
    boundingRects = NULL;
    
    positionsGlyph = calloc(nGlyphsCount, sizeof(CGPoint));
    boundingRects = calloc(nGlyphsCount, sizeof(CGRect));
    
    CTFontGetBoundingRectsForGlyphs (tfontref,
                                     kCTFontDefaultOrientation,
                                     glyphs,
                                     boundingRects,
                                     nGlyphsCount);
    
    fOffsets = 0;
    for (int i = 0; i < nGlyphsCount; i++)
    {
        positionsGlyph[i].x = m_points[0].x+m_nRadius1*2+10+fOffsets;
        positionsGlyph[i].y = 0;
        
        fOffsets += boundingRects[i].size.width + fSpacing;
    }
    
    CGContextShowGlyphsAtPositions (layContext, glyphs, positionsGlyph, nGlyphsCount);
    
    free(boundingRects);
    free(positionsGlyph);
    free(pGlyphsBuff);
    
    CGFontRelease(fontRef);
    
    CGColorRelease(color);
    CGContextRestoreGState(layContext);
}

// Слой текущего уровня температуры  - элипс
- (void) createLayTherm3_2: (CGContextRef) context
{
    if (m_layTherm3_2 != NULL)
    {
        CGLayerRelease(m_layTherm3_2);
        m_layTherm3_2 = NULL;
    }
    
    long nTemper = Temperature;
    if (nTemper > 40) nTemper = 40;
    else if (nTemper < -30) nTemper = -30;
    
    [self createPath3: nTemper];
    
    CGSize laySize = CGSizeMake(m_pixelsWide, m_pixelsHigh);
    m_layTherm3_2 = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_layTherm3_2);
    
    CGContextAddPath(layContext, m_path3);
    
    size_t numComponents = 4;
    CGFloat fPos = (Temperature+30.0)/70.0;
    CGFloat colorMask[4];
    
    myCalculateShadingValues ((void*)numComponents,
                              &fPos,
                              colorMask);
    
    CGContextSetRGBFillColor (layContext, colorMask[0], colorMask[1], colorMask[2], colorMask[3]);
    CGContextSetRGBStrokeColor(layContext, 1, 1, 1, 1);
    
    CGContextDrawPath (layContext, kCGPathFillStroke);
    //CGContextFillPath(layContext);
}

- (void) createLay4: (CGContextRef) context
{
    if (m_lay4 != NULL) CGLayerRelease(m_lay4);
    
    CGSize laySize = CGSizeMake(m_pixelsWide, m_pixelsHigh);
    m_lay4 = CGLayerCreateWithContext (context, laySize, NULL);
    
    CGContextRef layContext = CGLayerGetContext (m_lay4);
    
    CGColorSpaceRef colorSpaceRef = CGBitmapContextGetColorSpace (context);
    CGFloat colorComp[4];
    colorComp[0] = 190.0/255;
    colorComp[1] = 190.0/255;
    colorComp[2] = 190.0/255;
    colorComp[3] = 0.7;
    
    CGColorRef color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetFillColorWithColor (layContext, color);
    
    CGContextFillRect(layContext, CGRectMake(0, 0, m_pixelsWide, m_pixelsHigh));

    CGColorRelease(color);
}

- (CGContextRef) CreateBitmapContext
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    bitmapBytesPerRow   = (m_pixelsWide * 4);                   // 4 байта = 32 бита
    bitmapByteCount     = (bitmapBytesPerRow * m_pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    bitmapData = calloc(1, bitmapByteCount);
    context = CGBitmapContextCreate (bitmapData,
                                     m_pixelsWide,
                                     m_pixelsHigh,
                                     8, // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedLast);
    if (context == NULL)
    {
        free (bitmapData);
        return NULL;
    }
    CGColorSpaceRelease(colorSpace);
    
    [self createLayTherm1: context];
    [self createLayTherm2: context];
    [self createLayTherm3: context];
    [self createLayTherm3_2: context];
    [self createLay4: context];
    
    CGContextDrawLayerAtPoint (context, CGPointMake(0,0), m_lay4);
    
    CGContextDrawLayerAtPoint (context, CGPointMake(0,0), m_layTherm1);
    CGContextDrawLayerAtPoint (context, CGPointMake(0,0), m_layTherm3_2);   // текущий уровень температуры
    
    CGContextDrawLayerAtPoint (context, CGPointMake(0,0), m_layTherm2);     // контуры термометра
    
    CGContextDrawLayerAtPoint (context, CGPointMake(0,0), m_layTherm3);     // Слой с текстом температуры
    
    return context;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.*/
- (void)drawRect:(CGRect)rect
{
    if (bmpElemTherm != nil)
    {
        void *bitmapData = NULL;
        // Удаление графического контекста
        bitmapData = CGBitmapContextGetData(bmpElemTherm);
        CGContextRelease(bmpElemTherm);
        bmpElemTherm = nil;
        if (bitmapData) free(bitmapData);
    }
    bmpElemTherm = [self CreateBitmapContext];
    
    // Drawing code
    CGContextRef drawContext = UIGraphicsGetCurrentContext();
    CGRect myBoundingBox = self.bounds;
    
    CGImageRef myImage = CGBitmapContextCreateImage (bmpElemTherm);
    CGContextDrawImage(drawContext, myBoundingBox, myImage);
}

- (void)layoutSubviews
{
    m_pixelsWide = self.bounds.size.width;
    m_pixelsHigh = self.bounds.size.height;
    
    m_sx = m_pixelsHigh/m_InitHih;
    m_sy = m_sx;
    m_transform = CGAffineTransformMakeScale (m_sx, m_sy);
    
    if (bmpElemTherm != nil)
    {
        void *bitmapData = NULL;
        // Удаление графического контекста
        bitmapData = CGBitmapContextGetData(bmpElemTherm);
        CGContextRelease(bmpElemTherm);
        bmpElemTherm = nil;
        if (bitmapData) free(bitmapData);
    }
    
    [self setNeedsDisplay];
}
@end
