CREATE VIEW [TABSAP].[DimMaterialGroup5] AS 
--BI-12996 New View 
SELECT 
  MVGR5 as [MaterialGroup5] 
FROM 
  [SrcSAP].[TVM5];