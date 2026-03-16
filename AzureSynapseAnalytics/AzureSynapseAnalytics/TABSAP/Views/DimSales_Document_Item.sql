CREATE VIEW [TABSAP].[DimSales_Document_Item] AS 
--BI-12996 New View
Select 
  Distinct Replace(
    LTRIM(
      Replace([POSNR], '0', ' ')
    ), 
    ' ', 
    '0'
  ) as [Sales Document Item] 
from 
  SrcSAP.VBAP;