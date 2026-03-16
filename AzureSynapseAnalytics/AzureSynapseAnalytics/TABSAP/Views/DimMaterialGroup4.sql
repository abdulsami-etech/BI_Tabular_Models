CREATE VIEW [TABSAP].[DimMaterialGroup4] AS 
--BI-12996 New View 
SELECT 
  DISTINCT MVGR4 as [Material Group 4] 
FROM 
  [SrcSAP].[VBAP];