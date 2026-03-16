CREATE VIEW [TABSAP].[DimReportingChannel]
AS SELECT DISTINCT transpose.[WW015] as [Reporting Channel],
rchm.BEZEK as [Reporting Channel Text]

 FROM [DWSAP].[FactCOPATranspose] transpose
 INNER JOIN SrcSAP.T25A3 rchm on rchm.WW015 = transpose.WW015;