CREATE VIEW [TABSAP].[DimBaseUnitofMeasure] AS 
--BI-12996 New View
SELECT 
  DISTINCT MEINS [Base Unit of Measure] 
FROM 
  [SrcSAP].[VBAP];
