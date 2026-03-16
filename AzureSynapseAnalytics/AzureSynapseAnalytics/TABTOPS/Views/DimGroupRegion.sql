CREATE VIEW [TABTOPS].[DimGroupRegion]
AS SELECT 
	ROW_NUMBER() OVER (ORDER BY [GroupRegion]) AS SKGroupRegion,
	A.[GroupRegion]
FROM (SELECT DISTINCT [GroupRegion] FROM [DWTOPS].[DimTeamRegion]) A;