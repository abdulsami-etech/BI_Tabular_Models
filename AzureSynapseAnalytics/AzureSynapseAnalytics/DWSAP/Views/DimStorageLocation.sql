--BI-12996 New View
CREATE VIEW [TABSAP].[DimStorageLocation] AS 
SELECT 
  DISTINCT LGORT as [Storage Location], 
  '' [StorageLocationText] 
FROM 
  SrcSAP.[VBAP];
