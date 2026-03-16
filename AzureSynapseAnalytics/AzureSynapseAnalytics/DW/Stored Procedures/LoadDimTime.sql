CREATE PROC [DW].[LoadDimTime] AS
BEGIN

	IF OBJECT_ID('tempdb..#times') IS NOT NULL
		DROP TABLE #times

	;with times as  (
	SELECT convert(time(0), DATEADD(MINUTE, 1 * (rn - 1), '19000101 00:00:00')) as time_value
	from (
		select row_number() over (order by (select 0)) as rn
		FROM sys.all_columns a
		CROSS JOIN sys.all_columns b
	) t
	where rn <= 1440
	)
	SELECT 
		CAST(REPLACE(CONVERT(VARCHAR(8), time_value, 114), ':', '') AS INT) AS [SKTime],
		CAST(time_value AS TIME(0)) AS [KeyTime],
		CONVERT(VARCHAR(5), time_value, 114) AS [Time],
		CASE WHEN time_value BETWEEN '1900-01-01 00:00:00' AND '1900-01-01 11:59:59' THEN 'am' ELSE 'pm' END AS [AmPm],
		CASE WHEN DATEPART(hh, time_value) < 10
			THEN '0' + CAST(DATEPART(hh,time_value) AS CHAR(1)) 
			ELSE CAST(DATEPART(hh, time_value) AS CHAR(2))	
		END AS [MilitaryHour],
		CONVERT(VARCHAR(5), time_value, 114) AS [MilitaryTime], 
		DATEPART(mi, time_value) AS [MinuteOfHour],
		CASE WHEN DATEPART(hh, time_value) % 12 < 10
			THEN '0' + CAST(DATEPART(hh, time_value) % 12 AS CHAR(1)) 
			ELSE CAST(DATEPART(hh, time_value) % 12 AS CHAR(2)) 	
		END AS [StandardHour],
		convert(varchar(5), 
			CASE WHEN DATEPART(hh, time_value) % 12 < 10
				THEN '0' + CAST(DATEPART(hh, time_value) % 12 AS CHAR(1)) 
				ELSE CAST(DATEPART(hh, time_value) % 12 AS CHAR(2)) 	
			END + RIGHT(CONVERT(VARCHAR(8), time_value, 114),6) 
		) AS [StandardTime],
		CASE 
			WHEN time_value = '1900-01-01 00:00:00' THEN 'Midnight'
			WHEN time_value = '1900-01-01 12:00:00' THEN 'Noon'
			WHEN time_value > '1900-01-01 00:00:00' AND time_value <= '1900-01-01 12:00:00' THEN 'Morning'
			WHEN time_value > '1900-01-01 12:00:00' AND time_value <= '1900-01-01 18:00:00' THEN 'Afternoon'
			ELSE 'Evening'
		END AS [TimeOfDay]
	into #times
	FROM times

	TRUNCATE TABLE [DW].[DimTime];

	INSERT INTO [DW].[DimTime] (
		[SKTime], 
		[KeyTime], 
		[Time], 
		[AmPm], 
		[MilitaryHour], 
		[MilitaryTime], 
		[MinuteOfHour], 
		[StandardHour], 
		[StandardTime], 
		[TimeOfDay]
	)
	SELECT 
		-1 AS [SKTime],
		NULL AS [KeyTime],
		'NA' AS [Time],
		'NA' AS [AmPm],
		'NA' AS [MilitaryHour],
		'NA' AS [MilitaryTime], 
		NULL AS [MinuteOfHour],
		'NA' AS [StandardHour],
		'NA' AS [StandardTime],
		'NA' AS [TimeOfDay]

	union all

	SELECT 
		[SKTime], 
		[KeyTime], 
		[Time], 
		[AmPm], 
		[MilitaryHour], 
		[MilitaryTime], 
		[MinuteOfHour], 
		[StandardHour], 
		[StandardTime], 
		[TimeOfDay]
	FROM #times
END
