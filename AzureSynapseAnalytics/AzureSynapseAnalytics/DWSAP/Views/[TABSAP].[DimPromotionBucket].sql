--BI-12996 New View
CREATE VIEW [TABSAP].[DimPromotionBucket] AS 
SELECT 
  DISTINCT ZZPROMO as [Promotion Bucket] 
FROM 
  SrcSAP.VBAP;
