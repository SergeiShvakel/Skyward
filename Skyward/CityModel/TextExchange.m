
#import "TextExchange.h"

@implementation cTextExchange
{
}

- (id) init
{
    self = [super init];
    if (self != nil)
    {
        m_sBuffer = [[NSString alloc] init];
        
        m_iFindTekPos = -1;
        m_sFindFieldName  = [[NSString alloc] init];
        
        unichar szRet[] = {0x0d00, 0x0a00, 0};
        m_separator = [[NSString alloc] initWithBytes:szRet length:(2*sizeof(unichar)) encoding:NSUnicodeStringEncoding];
    }
    
    return self;
}

- (id) initWithString: (NSString*) string
{
    self = [self init];
    if (self != nil)
    {
        if (string != nil)
            m_sBuffer = [[NSString alloc] initWithString:string];
    }
    
    return self;
}

- (id) initWithTextExchange: (cTextExchange*) newObj
{
    self = [self init];
    if (self != nil)
    {
        m_sBuffer = [[NSString alloc] initWithString:[newObj GetDataBuffer]];
        
        m_iFindTekPos = newObj->m_iFindTekPos;
        m_sFindFieldName  = [[NSString alloc] initWithString:newObj->m_sFindFieldName];

        m_separator = [[NSString alloc] initWithString:newObj->m_separator];
    }
    
    return self;
}

- (NSString*) GetSeparators
{
    return m_separator;
}

- (NSString*) GetDataBuffer
{
    return m_sBuffer;
}

- (void) SetDataBuffer: (NSString*) data
{
    m_sBuffer = [NSString stringWithString:data];
}

- (void) Clear
{
    m_sBuffer = [[NSString alloc] init];
    
    m_iFindTekPos = -1;
    m_sFindFieldName  = [[NSString alloc] init];
}

// метод помещает данные в буфер
- (void) _AddFieldValue:(NSString*) FieldName value:(NSString*) value
{
    NSString *sTmpStr = nil, *sFormValue = nil;
    
    sTmpStr = [NSString stringWithString:FieldName];
    
    sFormValue = [NSString stringWithString:sTmpStr];
    sFormValue = [sFormValue stringByAppendingString:[self GetSeparators]];
    
    sTmpStr = [NSString stringWithFormat:@"%d", [value length]];
    sFormValue = [sFormValue stringByAppendingString:sTmpStr];
    sFormValue = [sFormValue stringByAppendingString:[self GetSeparators]];
    
    sFormValue = [sFormValue stringByAppendingString:value];
    sFormValue = [sFormValue stringByAppendingString:[self GetSeparators]];
    
    m_sBuffer = [m_sBuffer stringByAppendingString:sFormValue];
}

/*
    Метод возвращает стартовую позицию данных и длину блока данных.
 
    DataBuff - указатель на блок данных
    BlockName - полное название блока, включая [] - если необходимо
    fromPos - позиция начала названия блока - in
            - позиция начала данных блока - out
    outLenBlock - длина блока с данными (в символах)
*/
- (cTextEchangeReturn) _GetLenBlock: (NSString*) DataBuff blockName: (NSString*) BlockName fromPos: (NSInteger*) fromPos outLenBlock: (NSInteger*) outLenBlock
{
    @try
    {
        NSCharacterSet *DigitsSet = nil;
        DigitsSet = [NSCharacterSet decimalDigitCharacterSet];
        
        NSString *sNumber = @("");
        
        NSInteger iTekPos = *fromPos;
        
        // пропускаем название блока и разделители
        iTekPos += [BlockName length];
        
        // далее идет число до разделителей, берем пока цифры
        NSRange findRange, TekRange;
        TekRange = NSMakeRange(iTekPos, 1);
        findRange = [DataBuff rangeOfCharacterFromSet: DigitsSet options: NSLiteralSearch range:TekRange];
        
        while (!(findRange.location == NSNotFound && findRange.length == 0))
        {
            sNumber = [sNumber stringByAppendingString:[DataBuff substringWithRange:findRange] ];
            
            iTekPos++;
            TekRange = NSMakeRange(iTekPos, 1);
            findRange = [DataBuff rangeOfCharacterFromSet: DigitsSet options: NSLiteralSearch range:TekRange];
        }
        
        if ([sNumber length] == 0) // не добавили ни одной цифры, т.е. плохо
        {
            TextExchangeException* exit_code = [TextExchangeException
                                                exceptionWithCode: TXTEXCHANGE_ERR_UNKERROR];
            @throw exit_code;
        }
        
        // прокручиваем до начала данных
        iTekPos += [[self GetSeparators] length];
        *fromPos = iTekPos;
        
        *outLenBlock = [sNumber integerValue];
        
        TextExchangeException* exit_code = [TextExchangeException
                                            exceptionWithCode: TXTEXCHANGE_ERR_NOERROR];
        @throw exit_code;
    }
    @catch (TextExchangeException *error)
    {
        NSDictionary *dict = error.userInfo;
        if (dict)
        {
            NSNumber *number = nil;
            number = [dict objectForKey:@"code"];
            if (number)
                return number.integerValue;
        }
        
        return TXTEXCHANGE_ERR_UNKERROR;
    }
}

/*
    Метод получает данные поля FieldName
    из буфера данных lpszBuffer
    возвращает код ошибки
*/
- (cTextEchangeReturn) _GetFieldValue:(NSString*)buffer FieldName: (NSString*)FieldName Value: (NSString**)Value;
{
    @try {
        //lpszValue = _T("");
        
        //NSCopyMemoryPages
        //LPTSTR lpFindPointer = NULL;
        //int iFindIndex = 0;
        //if((lpFindPointer = _tcsstr(lpszBuffer, lpszFieldName)) == NULL)
        //    return TXTEXCHANGE_ERR_FIELD_NOTFOUND;
        
        NSRange findRange;
        findRange = [buffer rangeOfString: FieldName];
        if (findRange.location == NSNotFound && findRange.length == 0)
        {
            TextExchangeException* exit_code = [TextExchangeException
                                                exceptionWithCode: TXTEXCHANGE_ERR_FIELD_NOTFOUND];
            @throw exit_code;
        }
        
        // должны получить длину блока и начало данных
        //iFindIndex = ((DWORD)lpFindPointer - (DWORD)lpszBuffer) / sizeof(TCHAR); // чтобы в символах
        NSInteger iFromPos = findRange.location, iLenData = 0;
        if ([self _GetLenBlock: buffer blockName:FieldName fromPos:&iFromPos outLenBlock:&iLenData] == TXTEXCHANGE_ERR_UNKERROR)
        {
            TextExchangeException* exit_code = [TextExchangeException
                                                exceptionWithCode: TXTEXCHANGE_ERR_UNKERROR];
            @throw exit_code;
        }
        
        //lpFindPointer = (LPTSTR)((DWORD)lpszBuffer + iFindIndex);
        //lpszValue = lpFindPointer;
        //lpszValue = lpszValue.Left(iLenData);
        
        findRange.location = iFromPos;
        findRange.length = iLenData;
        *Value = [buffer substringWithRange:findRange];
        
        TextExchangeException* exit_code = [TextExchangeException
                                            exceptionWithCode: TXTEXCHANGE_ERR_NOERROR];
        @throw exit_code;
    }
    @catch (TextExchangeException *error)
    {
        NSDictionary *dict = error.userInfo;
        if (dict)
        {
            NSNumber *number = nil;
            number = [dict objectForKey:@"code"];
            if (number)
                return number.integerValue;
        }
        
        return TXTEXCHANGE_ERR_UNKERROR;
    }
}

//------------------------------------------------------------------------
// Добавляется секция  [SectionName] и данные StrValue
- (void) AddOptField: (NSString*) SectionName StrValue: (NSString*) Value
{
    NSString *sTmpStr = nil;
    sTmpStr = [NSString stringWithFormat:@"[%@]", SectionName];
    
    [self _AddFieldValue:sTmpStr value:Value];
}

- (void) AddField: (NSString*) FieldName StrValue: (NSString*) Value;
{
    [self _AddFieldValue: FieldName value: Value];
}

//------------------------------------------------------------------------
// Выбирается секция с данными [SectionName] в буфер данных DataBuf
- (cTextEchangeReturn) GetOptField: (NSString*) SectionName OutData: (NSString**)DataBuff
{
    cTextEchangeReturn lRet = 0;
        
    NSString *sTmpStr = nil;
    sTmpStr = [NSString stringWithFormat:@"[%@]", SectionName];
    sTmpStr  = [sTmpStr stringByAppendingString:[self GetSeparators]];
    
    if ((lRet = [self _GetFieldValue:m_sBuffer FieldName: sTmpStr Value: DataBuff]) != TXTEXCHANGE_ERR_NOERROR)
    {
        return lRet;
    }
        
    return TXTEXCHANGE_ERR_NOERROR;
}

- (cTextEchangeReturn) GetNeedField: (NSString*) FieldName OutData: (NSString**)DataBuff
{
    cTextEchangeReturn lRet = 0;
    
    NSString *sTmpStr = nil;
    sTmpStr = [NSString stringWithFormat:@"%@", FieldName];
    sTmpStr  = [sTmpStr stringByAppendingString:[self GetSeparators]];
    
    if ((lRet = [self _GetFieldValue:m_sBuffer FieldName: sTmpStr Value: DataBuff]) != TXTEXCHANGE_ERR_NOERROR)
    {
        return lRet;
    }
    
    return TXTEXCHANGE_ERR_NOERROR;
}

- (bool) FindFirstBlock:(NSString*)FieldName OutData:(NSString**)DataBuff
{
    m_iFindTekPos = 0;
    m_sFindFieldName = FieldName;
    m_sFindFieldName = [m_sFindFieldName stringByAppendingString:[self GetSeparators]];
    
    // Определяем блок, в котром будем искать данные
    NSString *sTmpBlock = nil;
    NSRange range;
    range.location = m_iFindTekPos;
    range.length = [m_sBuffer length] - m_iFindTekPos;
    sTmpBlock = [m_sBuffer substringWithRange:range];
    if (sTmpBlock == nil)
        return false;
    
    /*LPTSTR lpFindPointer = NULL;
    int iFindIndex = 0;
    if((lpFindPointer = _tcsstr(sTmpBlock, m_sFindFieldName)) == NULL)
        return FALSE;*/
    
    // Находим первое вхождение поля в блоке
    NSRange findRange;
    findRange = [sTmpBlock rangeOfString: m_sFindFieldName];
    if (findRange.location == NSNotFound && findRange.length == 0)
        return false;
    
    //iFindIndex = ((DWORD)lpFindPointer - (DWORD)(LPCTSTR)sTmpBlock) / sizeof(TCHAR);
    
    //long lRet = 0;
    //if ((lRet = _GetFieldValue(sTmpBlock, m_sFindFieldName, oFindBlock.GetDataBuffer())) != TXTEXCHANGE_ERR_NOERROR)
    //    return FALSE;
    
    // Получаем данные блока
    cTextEchangeReturn lRet = 0;
    if ((lRet = [self _GetFieldValue:sTmpBlock FieldName: m_sFindFieldName Value: DataBuff]) != TXTEXCHANGE_ERR_NOERROR)
    {
        return false;
    }
    
    // Передвигаем указатель на следующий блок
    NSInteger iFromPos = findRange.location, iLenData = 0;
    if ([self _GetLenBlock: sTmpBlock blockName:m_sFindFieldName fromPos:&iFromPos outLenBlock:&iLenData] == TXTEXCHANGE_ERR_UNKERROR)
    {
        return false;
    }
    
    m_iFindTekPos += iFromPos;
    m_iFindTekPos += [*DataBuff length];
    
    return true;
}

- (bool) FindNextBlock:(NSString**)DataBuff
{
    if ([m_sFindFieldName length] == 0)
        return false;
    
    if (m_iFindTekPos >= [m_sBuffer length])
        return false;
    
    // Определяем блок, в котром будем искать данные
    NSString *sTmpBlock = nil;
    NSRange range;
    range.location = m_iFindTekPos;
    range.length = [m_sBuffer length] - m_iFindTekPos;
    sTmpBlock = [m_sBuffer substringWithRange:range];
    if (sTmpBlock == nil)
        return false;
    
    // Находим первое вхождение поля в блоке
    NSRange findRange;
    findRange = [sTmpBlock rangeOfString: m_sFindFieldName];
    if (findRange.location == NSNotFound && findRange.length == 0)
        return false;
        
    // Получаем данные блока
    cTextEchangeReturn lRet = 0;
    if ((lRet = [self _GetFieldValue:sTmpBlock FieldName: m_sFindFieldName Value: DataBuff]) != TXTEXCHANGE_ERR_NOERROR)
    {
        return false;
    }
    
    // Передвигаем указатель на следующий блок
    NSInteger iFromPos = findRange.location, iLenData = 0;
    if ([self _GetLenBlock: sTmpBlock blockName:m_sFindFieldName fromPos:&iFromPos outLenBlock:&iLenData] == TXTEXCHANGE_ERR_UNKERROR)
    {
        return false;
    }
    
    m_iFindTekPos += iFromPos;
    m_iFindTekPos += [*DataBuff length];
    
    return true;
}

@end