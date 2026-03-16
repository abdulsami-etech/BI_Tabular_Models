--BI-12996 New View
CREATE VIEW [TABSAP].[DimVolumeUnit] AS 
SELECT 
  DISTINCT [Volume Unit] 
FROM 
  (
    SELECT 
      MSEHI as [Volume Unit] 
    FROM 
      SrcSAP.T006 t006 
      INNER JOIN SrcSAP.VBAP vbap On vbap.VOLEH = MSEHI 
    Union all 
    Select 
      'EA' AS [Volume Unit]
  ) Z;
