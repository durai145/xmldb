BEGIN
DBMS_XMLSCHEMA.registerschema('http://xmlns.oracle.com/xdb/ConnAuthSchema.xsd',
'<xsd:schema xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xdb="http://xmlns.oracle.com/xdb" xsi:schemaLocation="http://xmlns.oracle.com/xdb http://xmlns.oracle.com/xdb/ConnAuthSchema.xsd">'||
' <xsd:element name="ConnAuth" type="CONNAUTHType" xdb:SQLType="CONNAUTH" xdb:SQLSchema="R065908"/>'||
' <xsd:complexType name="CONNAUTHType" xdb:SQLType="CONNAUTH" xdb:SQLSchema="R065908" xdb:maintainDOM="false">'||
'  <xsd:sequence>'||
'   <xsd:element name="UserId" xdb:SQLName="USERID" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="8"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="PassWord" xdb:SQLName="PASSWORD" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="30"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="PublicKey" xdb:SQLName="PUBLICKEY" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="60"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="ReqType" xdb:SQLName="REQTYPE" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="1"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="Source" xdb:SQLName="SOURCE" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="30"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="SessionId" xdb:SQLName="SESSIONID" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="60"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="RequestTime" type="xsd:date" xdb:SQLName="REQUESTTIME" xdb:SQLType="DATE"/>'||
'   <xsd:element name="Status" xdb:SQLName="STATUS" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="10"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'   <xsd:element name="StatusDesc" xdb:SQLName="STATUSDESC" xdb:SQLType="VARCHAR2">'||
'    <xsd:simpleType>'||
'     <xsd:restriction base="xsd:string">'||
'      <xsd:maxLength value="300"/>'||
'     </xsd:restriction>'||
'    </xsd:simpleType>'||
'   </xsd:element>'||
'  </xsd:sequence>'||
' </xsd:complexType>'||
'</xsd:schema>',
     TRUE,
     FALSE,
     FALSE);
END;
/

