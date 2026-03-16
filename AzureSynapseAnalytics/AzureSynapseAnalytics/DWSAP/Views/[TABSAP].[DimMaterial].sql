--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterial] AS 
SELECT 
  Distinct a.MATKL as [Material Group], 
  a.MATNR as [Material Number], 
  b.MAKTX as [Material Text] 
FROM 
  SrcSAP.MARA a 
  LEFT JOIN SrcSAP.MAKT b ON a.MATNR = b.MATNR 
  AND b.SPRAS = 'E';
