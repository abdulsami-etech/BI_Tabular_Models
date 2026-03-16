CREATE VIEW [TABSAP].[DimComplianceIndicator] AS 
--BI-12996 New View
select 
  distinct ZZCOMP_IND as [Compliance Indicator] 
from 
  SrcSAP.VBAP;