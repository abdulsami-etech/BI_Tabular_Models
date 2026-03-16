--BI-12996 Alter View
Alter VIEW [TABSAP].[DimItemCategory] AS 
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
