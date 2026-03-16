CREATE VIEW [TABSAP].[DimRevenueRecognition] AS 
--BI-12996 New View
SELECT 
  DISTINCT [ZZTREV_DATE] as [Revenue Recognition] 
FROM 
  SrcSAP.VBAP;