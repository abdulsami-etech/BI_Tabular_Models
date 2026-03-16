--BI-12996 New View
CREATE VIEW [TABSAP].[DimSales_Document_Item] AS 
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
