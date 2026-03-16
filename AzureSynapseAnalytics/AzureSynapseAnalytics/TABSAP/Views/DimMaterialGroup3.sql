CREATE VIEW [TABSAP].[DimMaterialGroup3] 
AS 
--BI-12996 New View
SELECT 
  DISTINCT MVGR3 as [Material Group 3] 
FROM 
  [SrcSAP].[VBAP];
