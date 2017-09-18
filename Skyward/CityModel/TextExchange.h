// TextExchange.h: interface for the cTextExchange class.
//
/*
    Объявление класса CTextExchange - класс представляет набор методов для работы с буфером данных
    обмена информацией
    Формат файла:
    [Обязатальная_секция]
    <длина_в_байтах>
    <имя_параметра_1>
    <длина_в_байтах>
    <значение_1>
    ...
    <имя_параметра_n>
    <длина_в_байтах>
    <значение_n>
 
    Автор:  Швакель Сергей Евгеньевич
*/

#import <Foundation/Foundation.h>
#import "TextExchangeException.h"

typedef
enum{
    TXTEXCHANGE_ERR_NOERROR = 0,            //  метод выполнен без ошибок
    
    TXTEXCHANGE_ERR_UNKERROR = -1,
    TXTEXCHANGE_ERR_FIELD_NOTFOUND = -2,    // запрашиваемое поле не найдено в буфере
    
} cTextEchangeReturn;

@interface cTextExchange : NSObject
{
    NSString *m_sBuffer;
    
    NSInteger m_iFindTekPos;            // текущая позиция, откуда ищем следующий блок
    NSString *m_sFindFieldName;         // название поля
    
    NSString *m_separator;              // текущий разделитель полей
}

- (id) init;
- (id) initWithString: (NSString*) string;
- (id) initWithTextExchange: (cTextExchange*) newObj;

- (NSString*) GetSeparators;            // Возвращает разделитель

- (NSString*) GetDataBuffer;            // Возвращает буфер с данными
- (void) SetDataBuffer: (NSString*) data;

- (void) Clear;                         // Метод очищает буфер данных

// методы добавления значений в поля
- (void) AddOptField: (NSString*) SectionName StrValue: (NSString*) Value;
- (void) AddField: (NSString*) FieldName StrValue: (NSString*) Value;

- (cTextEchangeReturn) GetOptField: (NSString*) SectionName OutData: (NSString**)DataBuff;
- (cTextEchangeReturn) GetNeedField: (NSString*) FieldName OutData: (NSString**)DataBuff;

- (bool) FindFirstBlock:(NSString*)FieldName OutData:(NSString**)DataBuff;
- (bool) FindNextBlock:(NSString**)DataBuff;

@end

/*class CTextExchange
{
public:
	CTextExchange();
    CTextExchange(LPCTSTR lpszData);
    CTextExchange(const CTextExchange& oNewObj);

    CTextExchange& operator = (const CTextExchange& oNewObj);

	virtual ~CTextExchange(); 

private:
    // ƒ‡ÌÌ˚Â
    NSString *m_sBuffer;                  // “ÂÍÒÚÓ‚˚È ·ÛÙÂ ‰‡ÌÌ˚ı

private:
    // ÏÂÚÓ‰ ÔÓÏÂ˘‡ÂÚ ‰‡ÌÌ˚Â ‚ ·ÛÙÂ
    void _AddFieldValue(LPCTSTR lpszFieldName, LPCTSTR lpszValue);

    // ÏÂÚÓ‰ Á‡ÏÂ˘‡ÂÚ ‰‡ÌÌ˚Â ‚ ·ÛÙÂ
    void _ReplaceFieldValue(LPCTSTR lpszFieldName, LPCTSTR lpszValue);

    // ÏÂÚÓ‰ ÔÓÎÛ˜‡ÂÚ ‰‡ÌÌ˚Â ÔÓÎˇ lpszFiledName
    // ËÁ ·ÛÙÂ‡ ‰‡ÌÌ˚ı lpszBuffer
    // ‚ÓÁ‚‡˘‡ÂÚ ÍÓ‰ Ó¯Ë·ÍË
    long _GetFieldValue(LPCTSTR lpszBuffer, LPCTSTR lpszFieldName, CString& lpszValue);

    // ÏÂÚÓ‰ ‚ÓÁ‚‡˘‡ÂÚ ‰ÎËÌÛ ·ÎÓÍ‡
    // lpBuffer - ÛÍ‡Á‡ÚÂÎ¸ Ì‡ ·ÎÓÍ ‰‡ÌÌ˚ı
    // lpBlockName - ÔÓÎÌÓÂ Ì‡Á‚‡ÌËÂ ·ÎÓÍ‡, ‚ÍÎ˛˜‡ˇ [] - ÂÒÎË ÌÂÓ·ıÓ‰ËÏÓ
    // iPos - ÔÓÁËˆËˇ Ì‡˜‡Î‡ Ì‡Á‚‡ÌËˇ ·ÎÓÍ‡ - in
    //      - ÔÓÁËˆËˇ Ì‡˜‡Î‡ ‰‡ÌÌ˚ı ·ÎÓÍ‡ - out
    // iLenBlock - ‰ÎËÌ‡ ·ÎÓÍ‡ Ò ‰‡ÌÌ˚ÏË (‚ ÒËÏ‚ÓÎ‡ı)
    virtual long GetLenBlock(LPCTSTR lpBuffer/ *[in]* /, LPCTSTR lpBlockName/ *[in]* /, 
                             int& iPos/ *[in/out]* /, long& iLenBlock/ *[out]* /);

public:
    virtual CString GetSeparators(void);    // ¬ÓÁ‚‡˘‡ÂÚ ‡Á‰ÂÎËÚÂÎË

    CString& GetDataBuffer(void);           // ¬ÓÁ‚‡˘‡ÂÚ ·ÛÙÂ Ò ‰‡ÌÌ˚ÏË
    void SetDataBuffer(LPCTSTR lpszData);

    void Clear(void);                       // ÃÂÚÓ‰ Ó˜Ë˘‡ÂÚ ·ÛÙÂ ‰‡ÌÌ˚ı

    // ÏÂÚÓ‰˚ ‰Ó·‡‚ÎÂÌËˇ ÁÌ‡˜ÂÌËÈ ‚ ÔÓÎˇ
    void AddOptField(LPCTSTR lpszSectionName, LPCTSTR lpszDataBuf);

    void AddField(LPCTSTR lpszFieldName, LPCTSTR Value);
    void AddField(LPCTSTR lpszFieldName, UINT Value);
    void AddField(LPCTSTR lpszFieldName, long& Value);
    void AddField(LPCTSTR lpszFieldName, Date& Value);
    void AddField(LPCTSTR lpszFieldName, double& Value);

    // ÏÂÚÓ‰˚ ÔÓÎÛ˜ÂÌËˇ ÁÌ‡˜ÂÌËˇ ÔÓÎˇ ‚ ·ÎÓÍÂ
    long GetOptField(LPCTSTR lpszSectionName, CString& lpszDataBuf);

    long GetNeedField(LPCTSTR lpszFieldName, CString& Value);
    long GetNeedField(LPCTSTR lpszFieldName, UINT& Value);
    long GetNeedField(LPCTSTR lpszFieldName, long& Value);
    long GetNeedField(LPCTSTR lpszFieldName, int& Value);
    long GetNeedField(LPCTSTR lpszFieldName, Date& Value);
    long GetNeedField(LPCTSTR lpszFieldName, double& Value);

    // ÏÂÚÓ‰˚ ‰Îˇ ÔÓÒÎÂ‰Ó‚‡ÂÚÎ¸ÌÓ„Ó ÔÓËÒÍ‡ ·ÎÓÍÓ‚
    BOOL FindFirstBlock(LPCTSTR lpszFieldName, CTextExchange& oFindBlock);
    BOOL FindNextBlock(CTextExchange& oFindBlock);

    int m_iFindTekPos;              // ÚÂÍÛ˘‡ˇ ÔÓÁËˆËˇ, ÓÚÍÛ‰‡ Ë˘ÂÏ ÒÎÂ‰Û˛˘ËÈ ·ÎÓÍ
    CString m_sFindFieldName;       // Ì‡Á‚‡ÌËÂ ÔÓÎˇ

    // ÏÂÚÓ‰ ÏÂÌˇÂÚ ÁÌ‡˜ÂÌËÂ ‰Îˇ ÔÓÎˇ
    void ReplaceField(LPCTSTR lpszFieldName, LPCTSTR Value);
    void ReplaceField(LPCTSTR lpszFieldName, UINT Value);
    void ReplaceField(LPCTSTR lpszFieldName, Date& Value);

    operator LPCTSTR ();
};*/