//
//  SWCityResultSearchView.m
//  Skyward
//
//  Created by Сергей Швакель on 08.05.14.
//  Copyright (c) 2014 Сергей Швакель. All rights reserved.
//

#import "SWCityResultSearchView.h"
#import <CoreText/CTFont.h>

@implementation SWCityResultSearchView

- (id)initWithFrame:(CGRect)frame Cell: (SWCityResultSearchCell*) cell
{
    self = [super initWithFrame:frame];
    if (self) {
        m_cell = cell;
    }
    return self;
}

- (void) drawTextInRect:(CGRect)rect DrawContext:(CGContextRef) drawContext
             TextToDraw:(NSString*)textDraw FontName:(NSString*)fontName FontSize:(NSInteger)fontSize
{
    assert(textDraw);
    assert(fontName);
    
    CGFontRef fontRef = nil;
    CGFloat fSpacing = 1;
    
    //NSString *tempString = nil;
    unichar *strBuff = nil;
    void *pGlyphsBuff = nil;
    CGGlyph *glyphs = nil;
    CTFontRef tfontref = nil;
    NSRange range;
    CGFloat fXpos = 0.0, fYpos = 0.0;
    
    fXpos = rect.origin.x;
    fYpos = rect.origin.y;
    
    NSUInteger nGlyphsCount = 0;
    nGlyphsCount = [textDraw length];
    if (nGlyphsCount <= 0) return;
    
    range.location=0;
    range.length=[textDraw length];
    strBuff = calloc(range.length, sizeof(unichar));
    [textDraw getCharacters:strBuff range:range];
    
    fontRef = CGFontCreateWithFontName((__bridge CFStringRef)fontName);
    CGContextSetFont(drawContext, fontRef);
    CGContextSetFontSize (drawContext, fontSize);
    
    CGContextSetCharacterSpacing (drawContext, fSpacing);
    CGContextSetTextDrawingMode (drawContext, kCGTextFill);
    
    tfontref =  CTFontCreateWithName ((__bridge CFStringRef)fontName,
                                      fontSize,
                                      nil);
    
    pGlyphsBuff = calloc(nGlyphsCount, sizeof(CGGlyph));
    glyphs = (CGGlyph*)pGlyphsBuff;
    
    CTFontGetGlyphsForCharacters (tfontref,
                                  strBuff,
                                  glyphs,
                                  nGlyphsCount);
    
    // Меняем направление осей и масштаб
    CGContextSaveGState(drawContext);
    CGContextTranslateCTM(drawContext, 0, fYpos+fontSize);
    CGContextScaleCTM(drawContext, 1, -1);
    
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
        positionsGlyph[i].x = fXpos+fOffsets;
        positionsGlyph[i].y = 0;
        
        fOffsets += boundingRects[i].size.width + fSpacing;
    }
    
    // Цвет букв - белый
    CGContextSetRGBFillColor (drawContext, 1, 1, 1, 1);
    // Рисуем
    CGContextShowGlyphsAtPositions (drawContext, glyphs, positionsGlyph, nGlyphsCount);
    
    CGContextRestoreGState(drawContext);
    
    free(boundingRects);
    free(positionsGlyph);
    free(pGlyphsBuff);
    free(strBuff);
    
    CGFontRelease(fontRef);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGRect rectDraw;
    rectDraw = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    CGContextRef drawContext = UIGraphicsGetCurrentContext();
    
    // Выполняем заливку фона
    CGContextSetRGBFillColor (drawContext, 146.0/255, 174.0/255, 231.0/255, 1);
    CGContextFillRect(drawContext, rectDraw);
    
    //[m_cell.m_location.areaName drawInRect:rectDraw withAttributes:nil];
    CGRect rectAreaName, rectLocation;
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();//CGBitmapContextGetColorSpace (context);
    CGFloat colorComp[4];
    colorComp[0] = 190.0/255;
    colorComp[1] = 190.0/255;
    colorComp[2] = 190.0/255;
    colorComp[3] = 1;
    
    CGColorRef color = CGColorCreate(colorSpaceRef, colorComp);
    CGContextSetFillColorWithColor (drawContext, color);
    
    rectAreaName = CGRectMake(rect.origin.x+10, rect.origin.y,
                              rect.size.width, (rect.size.height/5)*3);
    
    [self drawTextInRect:rectAreaName DrawContext: drawContext
              TextToDraw:m_cell.m_location.areaName FontName:@"Helvetica-Bold" FontSize:16];
    
    rectLocation = CGRectMake(rect.origin.x+10,
                              rect.origin.y+(rect.size.height/5)*3,
                              rect.size.width,
                              (rect.size.height/5)*2);
    
    [self drawTextInRect:rectLocation DrawContext: drawContext
              TextToDraw:m_cell.m_location.country FontName:@"Helvetica" FontSize:14];
    
    CGColorRelease(color);
}

@end
