--BI-12996 New View
CREATE VIEW [TABSAP].[DimItemCategoryCOPA] AS 
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
