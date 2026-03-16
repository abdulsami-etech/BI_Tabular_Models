--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterialGroup3] AS 
SELECT 
  DISTINCT MVGR3 as [Material Group 3] 
FROM 
  [SrcSAP].[VBAP];
