CREATE VIEW [TABSAP].[DimPromotionBucket] AS 
--BI-12996 New View 
SELECT 
  DISTINCT ZZPROMO as [Promotion Bucket] 
FROM 
  SrcSAP.VBAP;