CREATE PROC [DWSAP].[LoadCopaProdh_Performance] AS 
--BI-12996 New procedure
--This procedure is responsible for updating product hierarchy
UPDATE 
  DWSAP.FactCOPATranspose_Performance 
SET 
  PRODH = HIGH 
FROM 
  [SrcSAPFile].[BackendVarConfig] 
--filtering some conditions to update hierarchy
WHERE 
  CONCAT(
    '0000', [SrcSAPFile].[BackendVarConfig].LOW
  ) = DWSAP.FactCOPATranspose_Performance.KSTAR 
  AND [SrcSAPFile].[BackendVarConfig].NAME = 'ZBW_COPA' 
  AND [SrcSAPFile].[BackendVarConfig].PURPOSE = DWSAP.FactCOPATranspose_Performance.PRODH 
--Checking BUDAT between these dates and prodh lies in A1A1N102
  AND DWSAP.FactCOPATranspose_Performance.BUDAT BETWEEN '19000101' 
  AND '20180731' 
  AND DWSAP.FactCOPATranspose_Performance.BUDAT < '20170101' 
  AND PRODH = 'A1A1N102' 
  /*JIRA*/
UPDATE 
  DWSAP.FactCOPATranspose_Performance 
SET 
  PRODH = HIGH 
FROM 
  [SrcSAPFile].[BackendVarConfig] 
--filtering some conditions to update hierarchy
WHERE 
  CONCAT(
    '0000', [SrcSAPFile].[BackendVarConfig].LOW
  ) = DWSAP.FactCOPATranspose_Performance.KSTAR 
  AND [SrcSAPFile].[BackendVarConfig].NAME = 'ZBW_COPA' 
  AND [SrcSAPFile].[BackendVarConfig].PURPOSE = DWSAP.FactCOPATranspose_Performance.PRODH 
--Checking BUDAT between these dates and prodh not lies in A1A1N102
  AND DWSAP.FactCOPATranspose_Performance.BUDAT BETWEEN '19000101' 
  AND '20180731' 
  AND PRODH <> 'A1A1N102';