CREATE VIEW [TABSAP].[DimMaterialGroup1] AS 
--BI-12996 New View
SELECT 
  Distinct MVGR1 as [Material Group 1]
FROM 
  [SrcSAP].[TVM1];