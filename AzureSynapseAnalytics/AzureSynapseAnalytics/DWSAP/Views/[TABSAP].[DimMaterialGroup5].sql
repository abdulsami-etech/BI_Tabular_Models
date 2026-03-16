--BI-12996 New View
CREATE VIEW [TABSAP].[DimMaterialGroup5] AS 
SELECT 
  MVGR5 as [MaterialGroup5] 
FROM 
  [SrcSAP].[TVM5];
