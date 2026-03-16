Create VIEW [TABSAP].[OperationsDimMaterial] AS 
SELECT 
  DISTINCT MTART as [Material type], 
  replace(
    ltrim(
      replace(MATNR, '0', ' ')
    ), 
    ' ', 
    '0'
  ) as [Material Number] 
from 
  SrcSAP.MARA;
