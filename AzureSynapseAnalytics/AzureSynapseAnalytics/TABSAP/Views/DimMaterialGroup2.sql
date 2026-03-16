CREATE VIEW [TABSAP].[DimMaterialGroup2] AS 
--BI-12996 New View
SELECT 
  Distinct MVGR2 as [MaterialGroup2] 
FROM 
  [SrcSAP].[TVM2];