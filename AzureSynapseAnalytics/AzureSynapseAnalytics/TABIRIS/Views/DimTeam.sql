CREATE VIEW [TABIRIS].[DimTeam]
AS SELECT
	dt.[SKTeam]										as [SK Team],
	[TeamName]										as [Key Team],

	[TeamName]										as [Team Name]

FROM [DWIRIS].[HubTeam] ht
inner join [DWIRIS].[DimTeam] dt
	on dt.[SKTeam] = ht.[SKTeam];