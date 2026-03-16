--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterialGroup1] AS 
SELECT 
  Distinct MVGR1 as [Material Group 1] 
FROM 
  [SrcSAP].[TVM1];
