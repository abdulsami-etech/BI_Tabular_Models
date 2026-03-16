--BI-12996 New View
CREATE VIEW [TABSAP].[DimBaseUnitofMeasure] AS 
SELECT 
  DISTINCT MEINS [Base Unit of Measure] 
FROM 
  [SrcSAP].[VBAP];
