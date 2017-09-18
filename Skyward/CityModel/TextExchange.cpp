// TextExchange.cpp: implementation of the CTextExchange class.
//
//////////////////////////////////////////////////////////////////////

#include "TextExchange.h"

#include "TCHAR.H"

#ifdef _DEBUG
#undef THIS_FILE
static char THIS_FILE[]=__FILE__;
#define new DEBUG_NEW
#endif

//////////////////////////////////////////////////////////////////////
// Construction/Destruction
//////////////////////////////////////////////////////////////////////

CTextExchange::CTextExchange()
{
    m_sBuffer = _T("");

    m_iFindTekPos       = -1;
    m_sFindFieldName    = _T("");
}
//------------------------------------------------------------------------ 
CTextExchange::CTextExchange(LPCTSTR lpszData)
{
    m_sBuffer = lpszData;

    m_iFindTekPos       = -1;
    m_sFindFieldName    = _T("");
}
//------------------------------------------------------------------------ 
CTextExchange::CTextExchange(const CTextExchange& oNewObj)
{
    m_sBuffer = oNewObj.m_sBuffer;

    m_iFindTekPos = oNewObj.m_iFindTekPos;
    m_sFindFieldName = oNewObj.m_sFindFieldName;
}
//------------------------------------------------------------------------ 
CTextExchange::~CTextExchange()
{
}
//------------------------------------------------------------------------ 
CTextExchange& CTextExchange::operator = (const CTextExchange& oNewObj)
{
    m_sBuffer = oNewObj.m_sBuffer;

    m_iFindTekPos = oNewObj.m_iFindTekPos;
    m_sFindFieldName = oNewObj.m_sFindFieldName;

    return *this;
}
//------------------------------------------------------------------------ 
CString& CTextExchange::GetDataBuffer()
{
    return m_sBuffer;
}
//------------------------------------------------------------------------ 
void CTextExchange::SetDataBuffer(LPCTSTR lpszData)
{
    Clear();
    m_sBuffer = lpszData;
}
//------------------------------------------------------------------------ 
void CTextExchange::Clear(void)
{
    m_sBuffer.Empty();
    m_sBuffer.FreeExtra();
    m_sBuffer = _T("");
}

//------------------------------------------------------------------------
CString CTextExchange::GetSeparators(void)
{
    TCHAR szRet[3] = {0x0d, 0x0a, 0};
    return CString() + szRet;
}
//------------------------------------------------------------------------ 
long CTextExchange::GetLenBlock(LPCTSTR lpBuffer, LPCTSTR lpBlockName, int& iPos, long& iLenBlock)
{
    try
    {
        LPCTSTR lpszDigits = _T("0123456789");
        TCHAR szNumber[256] = _T("");

        int iTekPos = iPos,
            iNumPos =   0;;
        // пропускаем название блока и разделители
        iTekPos += _tcslen(lpBlockName);

        // далее идет число до разделителей, берем пока цифры
        iNumPos = 0;
        while (_tcschr(lpszDigits, lpBuffer[iTekPos]) != NULL)
        {
            szNumber[iNumPos++] = lpBuffer[iTekPos++];
        }
        szNumber[iNumPos] = 0;

        if (iNumPos == 0) // не добавили ни одной цифры, т.е. плохо
            throw TXTEXCHANGE_ERR_UNKERROR;

        // прокручиваем до начала данных
        iTekPos += _tcslen(GetSeparators());
        iPos = iTekPos;
        
        iLenBlock = _ttoi(szNumber);
        return iLenBlock;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
void CTextExchange::_AddFieldValue(LPCTSTR lpszFieldName, LPCTSTR lpszValue)
{
    CString sTmpStr = _T(""), sFormValue;

    sTmpStr.Format(_T("%s"), lpszFieldName);
    sFormValue += sTmpStr;
    sFormValue += GetSeparators();

    sTmpStr.Format(_T("%d"), _tcslen(lpszValue));
    sFormValue += sTmpStr;
    sFormValue += GetSeparators();

    sFormValue += lpszValue;
    sFormValue += GetSeparators();

    m_sBuffer += sFormValue;    
}
//------------------------------------------------------------------------ 
void CTextExchange::_ReplaceFieldValue(LPCTSTR lpszFieldName, LPCTSTR lpszValue)
{
    CString sTmpStr = _T(""), sFormValue;

    sTmpStr.Format(_T("%s"), lpszFieldName);
    sFormValue += sTmpStr;
    sFormValue += GetSeparators();

    sTmpStr.Format(_T("%d"), _tcslen(lpszValue));
    sFormValue += sTmpStr;
    sFormValue += GetSeparators();

    sFormValue += lpszValue;
    sFormValue += GetSeparators();

    CTextExchange oFindValue;
    if (FindFirstBlock(lpszFieldName, oFindValue)) 
    {
        /*
            ¬ блоке найдено значение с таким параметром, значение находитьс€ в oReplaceBlock
            Ќеобходимо подготовить полное описание блока, дл€ поиска
        */
        CTextExchange oReplaceBlock;
        oReplaceBlock.AddField(lpszFieldName, oFindValue.GetDataBuffer());
        
        int iPosBg = 0;
        if ((iPosBg = m_sBuffer.Find(oReplaceBlock.GetDataBuffer())) != -1)
        {
            LPTSTR lpszTextReplaceBuff = m_sBuffer.GetBuffer(m_sBuffer.GetLength() + sFormValue.GetLength() + 1);

            int iSizeReplaceBlock = oReplaceBlock.GetDataBuffer().GetLength();
            int iSizeSourceBlock = sFormValue.GetLength();
            int iDeltaSize = iSizeReplaceBlock - iSizeSourceBlock;
            iDeltaSize = iDeltaSize < 0 ? iDeltaSize * (-1) : iDeltaSize;

            if (iSizeReplaceBlock < iSizeSourceBlock) // —двигаем вправо
            {
                MoveMemory(PVOID((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock + iDeltaSize), 
                       (CONST VOID *)((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock),
                       (_tcslen(LPTSTR((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock)) + 1) * sizeof(TCHAR));
            }
            else
            if (iSizeReplaceBlock > iSizeSourceBlock) // —двигаем влево
            {
                MoveMemory(PVOID((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock - iDeltaSize), 
                       (CONST VOID *)((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock),
                       (_tcslen(LPTSTR((DWORD)lpszTextReplaceBuff + iPosBg + iSizeReplaceBlock)) + 1) * sizeof(TCHAR));
            }
            
            // “еперь мен€ем
            CopyMemory(PVOID((DWORD)lpszTextReplaceBuff + iPosBg),
                        (LPCTSTR)sFormValue,
                        iSizeSourceBlock * sizeof(TCHAR));

            m_sBuffer.ReleaseBuffer();
        }
    }
    else
        m_sBuffer += sFormValue;
}

//------------------------------------------------------------------------ 
long CTextExchange::_GetFieldValue(LPCTSTR lpszBuffer, LPCTSTR lpszFieldName, CString& lpszValue)
{
    try
    {
        lpszValue = _T("");

        LPTSTR lpFindPointer = NULL;
        int iFindIndex = 0;
        if((lpFindPointer = _tcsstr(lpszBuffer, lpszFieldName)) == NULL)
            throw TXTEXCHANGE_ERR_FIELD_NOTFOUND;

        // должны получить длину блока и начало данных
        iFindIndex = ((DWORD)lpFindPointer - (DWORD)lpszBuffer) / sizeof(TCHAR); // чтобы в символах
        long iLenData = 0;
        if (GetLenBlock(lpszBuffer, lpszFieldName, iFindIndex, iLenData) == TXTEXCHANGE_ERR_UNKERROR)
            throw TXTEXCHANGE_ERR_UNKERROR;

        lpFindPointer = (LPTSTR)((DWORD)lpszBuffer + iFindIndex);
        lpszValue = lpFindPointer;
        lpszValue = lpszValue.Left(iLenData);
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}

//------------------------------------------------------------------------
// ƒобавл€етс€ секци€ [lpszSectionName] и данные lpszDataBuf
void CTextExchange::AddOptField(LPCTSTR lpszSectionName, LPCTSTR lpszDataBuf)
{
    CString sTmpStr = _T("");
    sTmpStr.Format(_T("[%s]"), lpszSectionName);

    _AddFieldValue(sTmpStr, lpszDataBuf);

}
//------------------------------------------------------------------------
void CTextExchange::AddField(LPCTSTR lpszFieldName, LPCTSTR Value)
{
    _AddFieldValue(lpszFieldName, Value);
}
//------------------------------------------------------------------------
void CTextExchange::AddField(LPCTSTR lpszFieldName, UINT Value)
{
    CString sVal = _T("");
    sVal.Format(_T("%d"), Value);

    _AddFieldValue(lpszFieldName, sVal);
}
//------------------------------------------------------------------------
void CTextExchange::AddField(LPCTSTR lpszFieldName, long& Value)
{
    CString sVal = _T("");
    sVal.Format(_T("%d"), Value);

    _AddFieldValue(lpszFieldName, sVal);
}
//------------------------------------------------------------------------
void CTextExchange::AddField(LPCTSTR lpszFieldName, Date& Value)
{
    TCHAR szTmpBuff[256];
    *szTmpBuff = 0;
    Value.ToStr(szTmpBuff, ddmmyyhhnnss);

    _AddFieldValue(lpszFieldName, szTmpBuff);
}
//------------------------------------------------------------------------
void CTextExchange::AddField(LPCTSTR lpszFieldName, double& Value)
{
    CString sVal = _T("");
    sVal.Format(_T("%f"), Value);

    _AddFieldValue(lpszFieldName, sVal);
}
//------------------------------------------------------------------------
// ¬ыбираетс€ секци€ [lpszSectionName] и данные lpszDataBuf
long CTextExchange::GetOptField(LPCTSTR lpszSectionName, CString& lpszDataBuf)
{
    try
    {
        long lRet = 0;

        CString sTmpStr = _T("");
        sTmpStr.Format(_T("[%s]"), lpszSectionName);
        sTmpStr += GetSeparators();

        if ((lRet = _GetFieldValue(m_sBuffer, sTmpStr, lpszDataBuf)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, CString& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, Value)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, UINT& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpValue, sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, sTmpValue)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;

        Value = _ttoi(sTmpValue);
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, long& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpValue, sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, sTmpValue)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;

        Value = _ttoi(sTmpValue);
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, int& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpValue, sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, sTmpValue)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;

        Value = _ttoi(sTmpValue);
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, Date& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpValue, sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, sTmpValue)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;

        Value.Reset(sTmpValue, ddmmyyhhnnss );
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
long CTextExchange::GetNeedField(LPCTSTR lpszFieldName, double& Value)
{
    try
    {
        long lRet = 0;
        CString sTmpValue, sTmpFieldName;
        sTmpFieldName = lpszFieldName + GetSeparators();
        if ((lRet = _GetFieldValue(m_sBuffer, sTmpFieldName, sTmpValue)) != TXTEXCHANGE_ERR_NOERROR)
            throw lRet;

        Value = atof(sTmpValue);
        
        throw TXTEXCHANGE_ERR_NOERROR;
    }
    catch (long lRet)
    {
        return lRet;
    }
}
//------------------------------------------------------------------------ 
BOOL CTextExchange::FindFirstBlock(LPCTSTR lpszFieldName, CTextExchange& oFindBlock)
{
    m_iFindTekPos = 0;
    m_sFindFieldName = lpszFieldName;
    m_sFindFieldName += GetSeparators();

    // получаем блок от текущей позиции до конца
    CString sTmpBlock;
    sTmpBlock = m_sBuffer.Mid(m_iFindTekPos, m_sBuffer.GetLength());

    LPTSTR lpFindPointer = NULL;
    int iFindIndex = 0;
    if((lpFindPointer = _tcsstr(sTmpBlock, m_sFindFieldName)) == NULL)
        return FALSE;
    // начало в блоке
    iFindIndex = ((DWORD)lpFindPointer - (DWORD)(LPCTSTR)sTmpBlock) / sizeof(TCHAR); // чтобы в символах

    // получаем данные блока
    long lRet = 0;
    if ((lRet = _GetFieldValue(sTmpBlock, m_sFindFieldName, oFindBlock.GetDataBuffer())) != TXTEXCHANGE_ERR_NOERROR)
        return FALSE;    

    // увеличиваем текущий указатель на длину блока и наименовани€ и на длину числа блока
    TCHAR szLen[32] = _T("");
    m_iFindTekPos += m_sFindFieldName.GetLength();
    m_iFindTekPos += oFindBlock.GetDataBuffer().GetLength();
    _itoa(oFindBlock.GetDataBuffer().GetLength(), szLen, 10);
    m_iFindTekPos += _tcslen(szLen);
    m_iFindTekPos += GetSeparators().GetLength();
    m_iFindTekPos += iFindIndex;
    
    return TRUE;
}
//------------------------------------------------------------------------ 
BOOL CTextExchange::FindNextBlock(CTextExchange& oFindBlock)
{
    if (m_iFindTekPos == -1 || m_sFindFieldName.IsEmpty())
        return FALSE;

    // получаем блок от текущей позиции до конца
    CString sTmpBlock;
    sTmpBlock = m_sBuffer.Mid(m_iFindTekPos, m_sBuffer.GetLength());

    LPTSTR lpFindPointer = NULL;
    int iFindIndex = 0;
    if((lpFindPointer = _tcsstr(sTmpBlock, m_sFindFieldName)) == NULL)
        return FALSE;
    // начало в блоке
    iFindIndex = ((DWORD)lpFindPointer - (DWORD)(LPCTSTR)sTmpBlock) / sizeof(TCHAR); // чтобы в символах

    // получаем данные блока
    long lRet = 0;
    if ((lRet = _GetFieldValue(sTmpBlock, m_sFindFieldName, oFindBlock.GetDataBuffer())) != TXTEXCHANGE_ERR_NOERROR)
        return FALSE;    

    // увеличиваем текущий указатель на длину блока и наименовани€ и на длину числа блока
    TCHAR szLen[32] = _T("");
    m_iFindTekPos += m_sFindFieldName.GetLength();
    m_iFindTekPos += oFindBlock.GetDataBuffer().GetLength();
    _itoa(oFindBlock.GetDataBuffer().GetLength(), szLen, 10);
    m_iFindTekPos += _tcslen(szLen);
    m_iFindTekPos += GetSeparators().GetLength();
    m_iFindTekPos += iFindIndex;

    return TRUE;
}
//------------------------------------------------------------------------ 
void CTextExchange::ReplaceField(LPCTSTR lpszFieldName, LPCTSTR Value)
{
    _ReplaceFieldValue(lpszFieldName, Value);
}
//------------------------------------------------------------------------ 
void CTextExchange::ReplaceField(LPCTSTR lpszFieldName, UINT Value)
{
    CString sVal = _T("");
    sVal.Format(_T("%d"), Value);

    _ReplaceFieldValue(lpszFieldName, sVal);
}
//------------------------------------------------------------------------ 
void CTextExchange::ReplaceField(LPCTSTR lpszFieldName, Date& Value)
{
    TCHAR szTmpBuff[256];
    *szTmpBuff = 0;
    Value.ToStr(szTmpBuff, ddmmyyhhnnss);

    _ReplaceFieldValue(lpszFieldName, szTmpBuff);
}
//------------------------------------------------------------------------ 
CTextExchange::operator LPCTSTR ()
{
    return (LPCTSTR)m_sBuffer;
}
//------------------------------------------------------------------------ 