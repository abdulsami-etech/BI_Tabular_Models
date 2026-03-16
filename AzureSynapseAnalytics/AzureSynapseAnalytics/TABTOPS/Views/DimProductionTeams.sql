CREATE VIEW [TABTOPS].[DimProductionTeams]
AS SELECT  
		DISTINCT [ProductionTeam] 
FROM [SrcMESCorp].[DC_at_ProductionTeamHstr] 
WHERE [ProductionTeam] IS NOT NULL  ;