CREATE VIEW [TABSAP].[DimDivision]
AS SELECT [SPRAS] as [Language Key],[SPART] as [Division],[VTEXT] as
 [Division Text],CONCAT(SPART,',',SPRAS) AS DIVISION_KEY FROM [SrcSAP].[TSPAT];