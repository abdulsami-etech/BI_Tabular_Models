Create VIEW [TABSAP].[DimItemCategory] AS 
--BI-12996 New View
SELECT 
  DISTINCT [Item Category] 
FROM 
  (
    SELECT 
      PSTYV as [Item Category] 
    FROM 
      SrcSAP.VBAP
  ) Z 
WHERE 
  [Item Category] <> 'Z000';
