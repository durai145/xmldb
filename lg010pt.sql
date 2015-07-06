/*[******************************************************************************
Name        : LG010PT

Author      : Duraimurugan G

TYPE        : PROCEDURE

TABLES USED : LG001TB


DATE        : 05-JUN-2010

******************************************************************************]*/

/*[*****************************************************************************

Main process of the Procedure
------------------------------

1. Receive the input as xml.


*****************************************************************************]*/

CREATE OR REPLACE  PROCEDURE lg010pt (inpXml in varchar2, outXml out varchar2)
AS

/*[*****************************************************************************
Define the user defined abstract data type
*****************************************************************************]*/
stage_code              VARCHAR2(10)    :='';
gl_reqDetCount          NUMBER          := 0;
gl_Cmn_ErrCd            VARCHAR2(3)     := 'OK';
gl_Cmn_ErrDesc          VARCHAR2(40)    := 'PROCESSED SUCCESSFULLY';

gl_errCd                NUMBER(5)       := 0;
gl_errDesc              VARCHAR2(500)   := '';

lc_corr_id              VARCHAR2(26)    := '';

TYPE FI010MB_REC        IS  RECORD (REC  FI010MB%ROWTYPE);

reqXml                  XMLTYPE; 
qryCtx                  DBMS_XMLGEN.ctxHandle;
result                  VARCHAR2(20000);
resultCommon            VARCHAR2(20000);
stage_desc              VARCHAR2(100);
dummy_dt                Date;

/*[*****************************************************************************
USER DEFINED EXCEPTION
*****************************************************************************]*/
transation_fails        EXCEPTION;
validation_fails        EXCEPTION;
logerr_exception        EXCEPTION;
invalid_number          EXCEPTION;
xml_parse_err           EXCEPTION;
xml_elemet_size_exceeds EXCEPTION;
obj_elemet_size_exceeds EXCEPTION;
pragma exception_init(xml_elemet_size_exceeds, -30951);
pragma exception_init(obj_elemet_size_exceeds, -22814);
pragma exception_init(xml_parse_err, -31011);
pragma exception_init(invalid_number, -6502);

/*[*****************************************************************************
USER DEFIND DATA TYPES VARIABLES
*****************************************************************************]*/
o_req                   ConnAuth ;
o_resp                  ConnAuth;

/*[*****************************************************************************
NAME     : Get_BrCd
DESC     : Convert Branch Short Code to Branh Code 
TYPE     : Procedure

s.no  parameter    in/out  datatype
-----------------------------------
1     in_Short_cd  in      varchar2 
*****************************************************************************]*/

/*[*****************************************************************************
NAME     : Generate_CorrId
DESC     : Frame the Correlation Id
TYPE     : PROCEDURE
*****************************************************************************]*/

PROCEDURE Generate_CorrId
AS
    CorrId       LG001TB.CORR_ID%TYPE := ''; 
    lc_uniqId    VARCHAR2(10)         := 'FTIBANKING';
BEGIN
--{
    BEGIN
    --{
        SELECT SUBSTR(NVL(TRIM(VALUE), 'FTIBANKING'), 1, 10)
        INTO   lc_uniqId
        FROM   CA840PB 
        WHERE  BR_CD  = '001101'
        AND    MOD_CD = 'MT'
        AND    KEY_1  = 'LG010PT_CALL'
        AND    KEY_2  = 'CORR_ID';

    EXCEPTION
    WHEN no_data_found THEN
        lc_uniqId := 'FTIBANKING';

    WHEN others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/LG010PT/While Selecting CORR_ID';
        RETURN;
    --}    
    END;    

    BEGIN
    --{
        SELECT SUBSTR(lc_uniqId,1,10) || TO_CHAR(SYSDATE,'DDMMYYYY') || 
               LPAD(FTICORRID_SEQ_NO.NEXTVAL,8,'0') 
        INTO   CorrId 
        FROM   DUAL;

    EXCEPTION
    WHEN others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/LG010PT/While Selecting CorrId';
        RETURN;
    --}
    END;

    lc_corr_id := CorrId;

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Generate_CorrId';
--}
END;

/*[****************************************************************************
Name   : Generate_Response_XML
Desc   : It will generate   Response xml from ft010tb object
*****************************************************************************/

PROCEDURE Generate_Response_XML
AS 
BEGIN
--{
    gl_errCd := 0;

    qryCtx := dbms_xmlgen.newContext(
              'SELECT RESPONSE FROM LG001TB WHERE CORR_ID = ''' || 
              lc_corr_id || '''');

    DBMS_XMLGEN.setMaxRows(qryCtx, 5);

    result := DBMS_XMLGEN.getXML(qryCtx);
              
    result := replace (result, '</DETAILREC>','');
    result := replace (result, '<DETAILREC>','');
    result := replace (result, '<ROWSET>','');
    result := replace (result, '</ROWSET>','');
    result := replace (result, '<ROW>','');
    result := replace (result, '</ROW>','');
    result := replace (result, '<RESPONSE/>','<ConnAuth/>');
    result := replace (result, '<RESPONSE>','<ConnAuth>');
    result := replace (result, '</RESPONSE>','</ConnAuth>');
--    result := replace (result, '<?xml version="1.0"?>','');
  result := replace (result, 'USERID',          'UserId');
  result := replace (result, 'PASSWORD',        'PassWord');
  result := replace (result, 'PUBLICKEY',       'PublicKey');
  result := replace (result, 'REQTYPE',         'ReqType');
  result := replace (result, 'SOURCE',          'Source');
  result := replace (result, 'SESSIONID',       'SessionId');
  result := replace (result, 'REQUESTTIME',     'RequestTime');
    dbms_output.put_line(result);

EXCEPTION
WHEN others  THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Generate_Response_XML';
--}
END;


/*[****************************************************************************
Name   : Insert_Req_In_LG001TB
Desc   : Insert the Request XML, CORR_ID into LG001TB.
*****************************************************************************/

PROCEDURE Insert_Req_In_LG001TB
AS PRAGMA AUTONOMOUS_TRANSACTION;
    lc_inpXml VARCHAR2(32767) := '';
    inpXmlTyp  xmlType;
BEGIN
--{
    BEGIN 
    --{
        lc_inpXml := inpXml;

        INSERT INTO LG001TB (CORR_ID, REQUESTXML) VALUES (lc_corr_id, lc_inpXml);

    EXCEPTION 
    WHEN xml_parse_err THEN
        gl_errCd   := 1;
        gl_errDesc := 'XML parsing failed' ;
        RETURN;

    WHEN xml_elemet_size_exceeds THEN
        gl_errCd   := 2;
        gl_errDesc := 'Exceeds'||substr(sqlerrm,instr(sqlerrm,'Xpath')+5,40) ;
        RETURN;

    WHEN others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/While inserting xml in LG001TB/'||sqlerrm;
        RETURN;
    --}
    END;

    COMMIT;

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG001TB/ in Insert_Req_In_LG001TB';
--}
END;
/****************************************************************************]*/

/*[****************************************************************************
Name   : Select_LG001TB_Req_Obj
Desc   : Select Reqest Object From LG001TB table.
*****************************************************************************/

PROCEDURE Select_LG001TB_Req_Obj
AS 
BEGIN
--{
    BEGIN
        SELECT REQUESTXML
        INTO reqXml
        FROM LG001TB
        WHERE CORR_ID = lc_corr_id;

    EXCEPTION 
    WHEN no_data_found  THEN
        gl_errCd   := 3;
        gl_errDesc := 'No data found in LG001TB';
        RETURN;

    WHEN others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/LG010PT/ while Selecting Req from LG001TB';
        RETURN;
    END;

    reqXml.toObject(o_req);

EXCEPTION
WHEN obj_elemet_size_exceeds THEN
    gl_errCd   := 2;
    gl_errDesc := 'attribute/element value is  limit exceeds';
    RETURN;

WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Select_LG001TB_Req_Obj';
--}
END;
/****************************************************************************]*/

/*[****************************************************************************
Name   : Update_Req_Res_LG001TB
Desc   : Update the Request Object in LG001TB table.
*****************************************************************************/

PROCEDURE Update_Req_Res_LG001TB
AS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
--{
    BEGIN
        UPDATE LG001TB 
        SET REQUEST   = o_req, 
            RESPONSE  = o_resp
        WHERE CORR_ID = lc_corr_id;

    EXCEPTION 
    WHEN others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/LG010PT/ while Updating REQ and RES in LG001TB';
        RETURN;
    END;

    COMMIT;

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Update_Req_Res_LG001TB';
--}
END;
/****************************************************************************]*/

/*[****************************************************************************
Name   : Update_Res_In_LG001TB
Desc   : After Financial Process, Update the Respone object in LG001TB.
*****************************************************************************/

PROCEDURE Update_Res_In_LG001TB
AS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN 
--{
    gl_errCd:=0;

    BEGIN
        UPDATE LG001TB
        SET RESPONSE  = o_resp
        WHERE CORR_ID = lc_corr_id;

    EXCEPTION 
    WHEN  others THEN
        gl_errCd   := 99;
        gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                      '/LG010PT/ while updating RES in LG001TB';
        RETURN;
    END;

    COMMIT;

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Update_Res_In_LG001TB';
--}
END;
/****************************************************************************]*/



PROCEDURE Update_XML_In_LG001TB
AS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
--{
    IF lc_corr_id is not null THEN
        BEGIN
            UPDATE LG001TB
            SET RESPONSEXML  = xmltype(result),
                ERR_CODE     = gl_Cmn_ErrCd,
                ERR_DESC     = gl_Cmn_ErrDesc
            WHERE CORR_ID = lc_corr_id;

        EXCEPTION
        WHEN others THEN
            gl_errCd   := 99;
            gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                          '/LG010PT/ while updating LG001TB - RESPONSEXML';
            RETURN;
        END;

        COMMIT;
    END IF;
RETURN;
EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Update_XML_In_LG001TB';
--}
END;

PROCEDURE Assign_Req_Res_CommonInfo
AS 
BEGIN
--{
     o_resp:=o_req;
     o_resp.source:='oasis.ind';
     o_resp.PublicKey:='india';
	
EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Assign_Req_Res_CommonInfo';
--}
END;


PROCEDURE Set_Default_Res_Namespace
AS
BEGIN
--{
    result := replace(result, '<ReplyMessage>', 
              '<ReplyMessage xsi:schemaLocation="http://www.test.com/gts/icg/ccd/service/CommonAccountPosting/Response OasisAccountPostingResp.xsd" xmlns="http://www.test.com/gts/icg/ccd/service/CommonAccountPosting/Response" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">');

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Set_Default_Res_Namespace';
--}
END;

PROCEDURE Log_Status (err_cd in number, err_msg1 in varchar, err_msg2 in varchar)
AS PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN  
--{
    INSERT INTO CA300HB (BR_CD, RUN_DT, MKR_ID, PGM_NAME, ERR_CD, ERR_MSG) VALUES
    ('001101', sysdate, 'FI010', 'LG010PT', err_cd, 
    substr(err_msg1 || ', SQLMSG :' || err_msg2, 1, 199));

    COMMIT;

EXCEPTION
WHEN others THEN
    gl_errCd   := 99;
    gl_errDesc := 'Tech. Error ' || to_char(sqlcode) ||
                  '/LG010PT/ in Log_Status';
--}
END;


/*******************************************************************************
Main Procedure Start Here
*******************************************************************************/

BEGIN
--{
    /****************************************************************************
    Initilise the err_cd and err_desc
    ****************************************************************************/
    gl_errCd   := 0;
    gl_errDesc := 'Successful';

    /****************************************************************************
    Frame the Default Response for other errors(Tech err)
    ****************************************************************************/
    stage_desc := 'Framing the response object XML text';

    resultCommon  := 
chr(10)||'<ConnAuth>'||
chr(10)||'<UserId>2232</UserId>'||
chr(10)||'<PassWord>@sss</PassWord>'||
chr(10)||'<PublicKey>INVALID XML OR TECH ERROR</PublicKey>'||
chr(10)||'<ReqType></ReqType>'||
chr(10)||'<Source>oracle<Source>'||
chr(10)||'<SessionId>js912121</SessionId>'||
chr(10)||'<RequestTime/>'||
chr(10)||'</ConnAuth>';

    /***********************************************************************
    Create the default  error response  object initilization
    ************************************************************************/
    stage_desc := 'Create the default error response initilization';

    o_resp            := ConnAuth('','','','','','','');

    /***********************************************************************
    Generate the Correlation id
    ************************************************************************/
    stage_desc := 'calling Generate_CorrId';
    Generate_CorrId;
    
    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Insert the request xml into LG001TB table.   
    ************************************************************************/
    stage_desc := 'calling Insert_Req_In_LG001TB <' || lc_corr_id || '>';

    Insert_Req_In_LG001TB;

    IF gl_errCd <>  0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Select the request xml from LG001TB table for object converting 
    ************************************************************************/
    stage_desc := 'calling Select_LG001TB_Req_Obj';

    Select_LG001TB_Req_Obj;

    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Frame Response CommonInfo Message Object 
    ************************************************************************/
    stage_desc := 'calling Assign_Req_Res_CommonInfo <' || lc_corr_id || '>' ;

    Assign_Req_Res_CommonInfo;

    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Update Request and Response object in LG001TB
    ************************************************************************/
    stage_desc := 'calling Update_Req_Res_LG001TB - Corr_id: <'||lc_corr_id||'>';

    Update_Req_Res_LG001TB;

    IF gl_errCd <>  0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Update Request and Response object in LG001TB.
    ************************************************************************/
    stage_desc := 'Update_Res_In_LG001TB Corr_id: <'||lc_corr_id||'>';

    Update_Res_In_LG001TB;

    IF gl_errCd <>  0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Generate the XML
    ************************************************************************/
    stage_desc := 'calling Generate_Response_XML <' || lc_corr_id || '>';

    Generate_Response_XML;

    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Final LG001TB xml update
    ************************************************************************/
    stage_desc := 'calling Update_XML_In_LG001TB <' || lc_corr_id || '>';
    Update_XML_In_LG001TB;

    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    /***********************************************************************
    Final Commit
    ************************************************************************/
    stage_desc := 'Final COMMIT';

    COMMIT;

    stage_desc := 'calling Set_Default_Res_Namespace <' || lc_corr_id || '>';

    Set_Default_Res_Namespace;

    IF gl_errCd <> 0 THEN
    --{
        RAISE logerr_exception;
    --}
    END IF;

    stage_desc := 'End of the process outXml <' || lc_corr_id || '>';
    outXml := result;

EXCEPTION
    WHEN logerr_exception THEN
        gl_Cmn_ErrCd   := 'MNK';
        gl_Cmn_ErrDesc := substr(gl_errDesc||'/'||stage_desc,1,40);

        result := replace(resultCommon, 'MNK', gl_Cmn_ErrCd);
        result := replace(result, 'INVALID XML OR TECH ERROR',substr( gl_errDesc,1,40));
--        result := replace(result, 'INVALID XML OR TECH ERROR',substr(gl_errDesc||'/'||gl_Cmn_ErrDesc ,1,40));
        ROLLBACK;
        Update_XML_In_LG001TB;

        Log_Status(gl_errCd, gl_errDesc, stage_desc);
        Set_Default_Res_Namespace;
        stage_desc := 'End of the process outXml <' || lc_corr_id || '>';
        outXml := result;
        return;

    WHEN others THEN
        ROLLBACK;
        Set_Default_Res_Namespace;
        Log_Status(gl_errCd, gl_errDesc, stage_desc || '/' || sqlerrm);
        outXml := resultCommon;
--}
END;
/
show err


