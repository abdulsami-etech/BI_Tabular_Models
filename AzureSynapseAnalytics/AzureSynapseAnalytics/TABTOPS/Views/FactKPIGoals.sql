CREATE VIEW [TABTOPS].[FactKPIGoals]
AS SELECT [SKDate]
		,[Date]
		,b.SKPlant
		,a.[KeyPlant]
		,[GroupRegion]
		,[MetricDescription]
		,[Value]
	FROM [DWTOPS].[FactKPIGoals] as a
	Left join [DWTOPS].[DimPlant] as b
	on a.KeyPlant=b.KeyPlant;