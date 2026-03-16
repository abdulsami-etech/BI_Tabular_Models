CREATE VIEW [TABSAP].[DimStorageLocation] AS 
--BI-12996 New View
SELECT 
  DISTINCT LGORT as [Storage Location], 
  '' [StorageLocationText] 
FROM 
  SrcSAP.[VBAP];