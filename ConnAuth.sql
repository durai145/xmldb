create or replace type	ConnAuth as object 
(
UserId			Varchar2(8)   ,
PassWord		Varchar2(30)  ,
PublicKey		Varchar2(60)  ,
ReqType			Varchar2(1)   ,
Source			Varchar2(30)  ,
SessionId		Varchar2(60)  ,
RequestTime		Date	      ,
status                  varchar2(10)  ,
statusDesc              varchar2(300)
)
/
