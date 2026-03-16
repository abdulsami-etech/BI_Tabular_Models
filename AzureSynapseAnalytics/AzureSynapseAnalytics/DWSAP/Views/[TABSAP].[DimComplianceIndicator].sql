--BI-12996 New View
CREATE VIEW [TABSAP].[DimComplianceIndicator] AS 
select 
  distinct ZZCOMP_IND as [Compliance Indicator] 
from 
  SrcSAP.VBAP;
