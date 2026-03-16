CREATE VIEW [TABSAP].[DimItemCategoryCOPA] AS 
--BI-12996 New View
SELECT 
  DISTINCT [Item Category] 
FROM 
  (
    SELECT 
      PSTYV as [Item Category] 
    FROM 
      SRcSAP.CE110US
  ) Z 
WHERE 
  [Item Category] <> 'Z000';