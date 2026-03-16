CREATE VIEW [TABTOPS].[DimGroupRegionPlant]
AS With PlantToGroupList
as
(
SELECT 
				CAST(CONCAT(GR.SKGroupRegion,DP.[SKPlant]) as int) AS SKGroupRegionPlant,
				GR.SKGroupRegion,
				DP.[SKPlant],
				CASE WHEN CHARINDEX('(',DP.[PlantDescription]) >0 then 
				      RTRIM(SUBSTRING(DP.[PlantDescription],1,CHARINDEX('(',DP.[PlantDescription])-1))   
				        else DP.[PlantDescription] end as PlantDescription,
				GR.[GroupRegion],
				CONCAT(CASE WHEN CHARINDEX('(',DP.[PlantDescription]) >0 then 
				      RTRIM(SUBSTRING(DP.[PlantDescription],1,CHARINDEX('(',DP.[PlantDescription])-1))   
				        else DP.[PlantDescription] end,CONCAT(' to ',GR.[GroupRegion])) AS [PlantToGroup]

			FROM 
				[TABTOPS].[DimGroupRegion] as GR
				INNER JOIN [TABTOPS].[DimPlant] DP ON 1=1
			WHERE
				DP.[SKPlant] > 0
				)
,PlantToGroupFilters
as
(
SELECT
		 SKGroupRegionPlant,
		 SKGroupRegion,
		 [SKPlant],
		 [PlantToGroup],
		 [ComplaintsGrouping] = CASE WHEN PlantToGroup IN ('CN-Chengdu to CHINA','CN-Chengdu to APAC')		then 'China'
						WHEN PlantToGroup IN ('DE-Köln to GERMANY','DE-Köln to EMEA')					then 'Germany'
						WHEN PlantToGroup IN ('SP-Madrid to SPAIN','SP-Madrid to EMEA')				    then 'Spain'
						WHEN PlantToGroup IN ('JP-Japan Plant to Japan YK','JP-Japan Plant to APAC')	then 'Japan'
						WHEN PlantToGroup = 'CR-San Jose to AMERICAS'									then 'Costa Rica - Americas'
						WHEN PlantToGroup = 'CR-San Jose to APAC'										then 'Costa Rica - APAC'
						WHEN PlantToGroup = 'CR-San Jose to EMEA'										then 'Costa Rica - EMEA'
						else PlantToGroup end,

         [CCMetricsGrouping] = CASE   WHEN PlantToGroup = 'CN-Chengdu to CHINA'			then 'China'
								WHEN PlantToGroup = 'CR-San Jose to AMERICAS'		then 'Costa Rica - Americas'
								WHEN PlantToGroup = 'CR-San Jose to APAC'			then 'Costa Rica - APAC'
								WHEN PlantToGroup = 'CR-San Jose to EMEA'			then 'Costa Rica - EMEA'
								WHEN PlantToGroup = 'DE-Köln to GERMANY'			then 'Germany'
								WHEN PlantToGroup = 'JP-Japan Plant to Japan YK'	then 'Japan'
								WHEN PlantToGroup = 'PL-Poland to GERMANY'			then 'Poland'
								WHEN PlantToGroup = 'PL-Poland to SPAIN'			then 'Poland'
								WHEN PlantToGroup ='SP-Madrid to SPAIN'				then 'Spain' 
								else PlantToGroup end ,
		 [CCMetricsFilter] = CASE    WHEN [PlantToGroup] = 'CN-Chengdu to CHINA'			 then 1
								WHEN  [PlantToGroup] = 'CR-San Jose to AMERICAS'	 then 1
								WHEN  [PlantToGroup] = 'CR-San Jose to APAC'		 then 1
								WHEN  [PlantToGroup] = 'CR-San Jose to EMEA'		 then 1
								WHEN  [PlantToGroup] = 'DE-Köln to GERMANY'			 then 1
								WHEN  [PlantToGroup] = 'JP-Japan Plant to Japan YK'	 then 1
								WHEN  [PlantToGroup] = 'PL-Poland to GERMANY'		 then 1
								WHEN  [PlantToGroup] = 'PL-Poland to SPAIN'			 then 1
								WHEN  [PlantToGroup] ='SP-Madrid to SPAIN'			 then 1 
								else 0 end,

		[ComplaintsFilter] = CASE WHEN [PlantToGroup] IN ('CN-Chengdu to CHINA','CN-Chengdu to APAC')			THEN 1
							WHEN [PlantToGroup] IN ('DE-Köln to GERMANY','DE-Köln to EMEA')				Then 1
							WHEN [PlantToGroup] IN ('SP-Madrid to SPAIN','SP-Madrid to EMEA')				THEN 1
							WHEN [PlantToGroup] IN ('JP-Japan Plant to Japan YK','JP-Japan Plant to APAC') then 1
							WHEN [PlantToGroup] = 'CR-San Jose to AMERICAS'									then 1
							WHEN [PlantToGroup] = 'CR-San Jose to APAC'										then 1
							WHEN [PlantToGroup] = 'CR-San Jose to EMEA'										THEN 1
							else 0 end
							From PlantToGroupList 
	)
	Select * from PlantToGroupFilters;