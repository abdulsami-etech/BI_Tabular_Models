--BI-12996 Alter View
Alter VIEW [DWSAP].[VBPA_Pivoted_v2] AS 
SELECT 
  * 
FROM 
  (
    SELECT 
      [VBELN], 
      [PARVW], 
      [KUNNR] 
    FROM 
      [SrcSAP].[VBPA]
  ) AS SourceTable PIVOT(
    MAX([KUNNR]) FOR [PARVW] IN (
      [WE], [RG], [RE], [AG], [ZE], [ZA], [ZM], 
      [ZF], [ZJ], [ZS], [ZT], [SP], [ZL]
    )
  ) AS PivotTable;
