--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterialGroup4] AS 
SELECT 
  DISTINCT MVGR4 as [Material Group 4] 
FROM 
  [SrcSAP].[VBAP];
