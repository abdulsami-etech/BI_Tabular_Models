--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterialGroup2] AS 
SELECT 
  Distinct MVGR2 as [MaterialGroup2] 
FROM 
  [SrcSAP].[TVM2];
