set serveroutput on size 10000
set head off
set feedback off
set long 200000
set linesize 1000
set longchunksize 1000
set pagesize 0
set trimspool on
set termout on
set echo off
set verify off
spool ConnAuthSchema.xsd
truncate table dbms_text;

declare
   tmpXml   XMLTYPE;
   tmpClob  CLOB;
   glLine   number(5) := 0;

   Procedure dbms_put(pText CLOB) as Pragma Autonomous_Transaction;
   Begin 
      glLine:= glLine +1;  
      insert into  dbms_text(text, line) values(pText, glLine); 
      commit;
   End;

begin
   tmpXml := DBMS_XMLSCHEMA.GENERATESCHEMA('R065908','CONNAUTH');--need to change your schema
   tmpClob := tmpXml.GETCLOBVAL();
   dbms_put(tmpClob);
end;
/

select * from dbms_text order by line;
spool off;
