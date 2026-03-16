--BI-12996 New View
CREATE VIEW [TABSAP].[DimRevenueRecognition] AS 
SELECT 
  DISTINCT [ZZTREV_DATE] as [Revenue Recognition] 
FROM 
  SrcSAP.VBAP;
