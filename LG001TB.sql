CREATE TABLE LG001TB(
   CORR_ID     VARCHAR2(50),
   REQUEST      ConnAuth,
   RESPONSE    ConnAuth,
   REQUESTXML  XMLTYPE,
   RESPONSEXML XMLTYPE,
   ERR_CODE    VARCHAR2(10),
   ERR_DESC    VARCHAR2(300))
   xmltype column REQUESTXML  XMLSCHEMA "http://xmlns.oracle.com/xdb/ConnAuthSchema.xsd"  Element "ConnAuth",
   xmltype column RESPONSEXML XMLSCHEMA "http://xmlns.oracle.com/xdb/ConnAuthSchema.xsd" Element "ConnAuth";
