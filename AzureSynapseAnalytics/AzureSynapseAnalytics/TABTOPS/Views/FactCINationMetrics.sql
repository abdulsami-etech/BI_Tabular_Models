CREATE VIEW [TABTOPS].[FactCINationMetrics]
AS
WITH rolling13months
AS (
	SELECT skdate
		,[Date]
		,calendarmonth
		,calendaryear
	FROM dw.dimdate
	WHERE calendarday = 1
		AND [Date] > Dateadd(month, - 13, Getdate())
		AND [Date] < Getdate()
	)
	,Submitted
AS (
	SELECT Cast(SUBSTRING(CreateDate, 1, 8) + '01' AS DATE) AS DateSk
		,Count(DISTINCT ideaID) AS SubmittedCount
	FROM [SrcKaiNexus].[itemList]
	GROUP BY Cast(SUBSTRING(CreateDate, 1, 8) + '01' AS DATE)
	)
	,Completed
AS (
	SELECT Cast(SUBSTRING(Completedate, 1, 8) + '01' AS DATE) AS DateSk
		,Count(DISTINCT ideaID) AS CompletedCount
		,Count(DISTINCT CASE 
				WHEN result = 'CHANGE'
					THEN ideaID
				END) AS ResultChangeCount
	FROM [SrcKaiNexus].[itemList] 
	WHERE Completedate IS NOT NULL AND Status ='COMPLETE'
	GROUP BY Cast(SUBSTRING(Completedate, 1, 8) + '01' AS DATE)
	)
	,Financial
AS (
	SELECT DateSk
		,SUM(Amount) AS FinancialImpactTotal
	FROM (
		SELECT Cast(SUBSTRING(Completedate, 1, 8) + '01' AS DATE) AS DateSk
			,IdeaID
			,TypeName
			,CASE 
				WHEN RecurringType = 'RANGE'
					THEN CAST(Amount AS DECIMAL(20, 2)) * COALESCE(NULLIF(DATEDIFF(month, (DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(SUBSTRING(RangeStartTime, 1, 10) AS DATETIME)), 0)) - 1, (DATEADD(SECOND, - 1, DATEADD(MONTH, 1, DATEADD(MONTH, DATEDIFF(MONTH, 0, CAST(SUBSTRING(RangeEndTime, 1, 10) AS DATETIME)), 0)))) + 1), 0) - 1, 0)
				WHEN RecurringType = 'RECURRING'
					AND RecurringInterval = 'MONTH'
					THEN CAST(Amount AS DECIMAL(20, 2)) * 12
				WHEN RecurringType = 'RECURRING'
					AND RecurringInterval = 'WEEK'
					THEN CAST(Amount AS DECIMAL(20, 2)) * 52.1429
				WHEN RecurringType = 'RECURRING'
					AND RecurringInterval = 'DAY'
					THEN CAST(Amount AS DECIMAL(20, 2)) * 365
				WHEN RecurringType = 'RECURRING'
					AND RecurringInterval = 'HOUR'
					THEN CAST(Amount AS DECIMAL(20, 2)) * 8760
				ELSE CAST(Amount AS DECIMAL(20, 2))
				END AS Amount
			,Row_Number() OVER (
				PARTITION BY IdeaID
				,TypeName
				,TypeID
				,ImpactedLocations ORDER BY Cast(SUBSTRING(LastUpdateDate, 1, 10) AS DATE) DESC
				) RNUM
		FROM [SrcKaiNexus].[itemList]
		WHERE Completedate IS NOT NULL AND Status ='COMPLETE'
			AND TypeName IN (
				'Cost Savings'
				,'Cost Avoidance'
				,'Revenue Generation'
				)
			AND RecurringType <> 'CUSTOM'
		
		UNION ALL
		
		SELECT Cast(SUBSTRING(Completedate, 1, 8) + '01' AS DATE) AS DateSk
			,IdeaID
			,TypeName
			,CAST(CustomAmount AS DECIMAL(20, 2)) AS Amount
			,Row_Number() OVER (
				PARTITION BY IdeaID
				,TypeName
				,TypeID
				,ImpactedLocations
				,CustomYear
				,CustomMonth
				,CustomAmount ORDER BY Cast(SUBSTRING(LastUpdateDate, 1, 10) AS DATE) DESC
				) RNUM
		FROM [SrcKaiNexus].[itemList]
		WHERE Completedate IS NOT NULL AND Status ='COMPLETE'
			AND TypeName IN (
				'Cost Savings'
				,'Cost Avoidance'
				,'Revenue Generation'
				)
			AND RecurringType = 'CUSTOM'
		) Financial
	WHERE RNUM = 1
	GROUP BY DateSk
	)
	,Timesaved
AS (
	SELECT DateSk
		,SUM(CASE 
				WHEN RecurringInterval IS NULL
					OR RecurringInterval = 'YEAR'
					THEN CASE 
							WHEN AmountTimeUnit = 'MONTH'
								THEN CAST(Amount AS NUMERIC(20, 5)) * 2628000
							WHEN AmountTimeUnit = 'WEEK'
								THEN CAST(Amount AS NUMERIC(20, 5)) * 604800
							WHEN AmountTimeUnit = 'DAY'
								THEN CAST(Amount AS NUMERIC(20, 5)) * 86400
							WHEN AmountTimeUnit = 'HOUR'
								THEN CAST(Amount AS NUMERIC(20, 5)) * 3600
							WHEN AmountTimeUnit = 'MINUTE'
								THEN CAST(Amount AS NUMERIC(20, 5)) * 60
							WHEN AmountTimeUnit = 'SECOND'
								THEN CAST(Amount AS NUMERIC(20, 5))
							END
				WHEN RecurringInterval = 'MONTH'
					THEN CASE 
							WHEN AmountTimeUnit = 'MONTH'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12) * 2628000
							WHEN AmountTimeUnit = 'WEEK'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12) * 604800
							WHEN AmountTimeUnit = 'DAY'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12) * 86400
							WHEN AmountTimeUnit = 'HOUR'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12) * 3600
							WHEN AmountTimeUnit = 'MINUTE'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12) * 60
							WHEN AmountTimeUnit = 'SECOND'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 12)
							END
				WHEN RecurringInterval = 'WEEK'
					THEN CASE 
							WHEN AmountTimeUnit = 'MONTH'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429) * 2628000
							WHEN AmountTimeUnit = 'WEEK'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429) * 604800
							WHEN AmountTimeUnit = 'DAY'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429) * 86400
							WHEN AmountTimeUnit = 'HOUR'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429) * 3600
							WHEN AmountTimeUnit = 'MINUTE'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429) * 60
							WHEN AmountTimeUnit = 'SECOND'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 52.1429)
							END
				WHEN RecurringInterval = 'DAY'
					THEN CASE 
							WHEN AmountTimeUnit = 'MONTH'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365) * 2628000
							WHEN AmountTimeUnit = 'WEEK'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365) * 604800
							WHEN AmountTimeUnit = 'DAY'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365) * 86400
							WHEN AmountTimeUnit = 'HOUR'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365) * 3600
							WHEN AmountTimeUnit = 'MINUTE'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365) * 60
							WHEN AmountTimeUnit = 'SECOND'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 365)
							END
				WHEN RecurringInterval = 'HOUR'
					THEN CASE 
							WHEN AmountTimeUnit = 'MONTH'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760) * 2628000
							WHEN AmountTimeUnit = 'WEEK'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760) * 604800
							WHEN AmountTimeUnit = 'DAY'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760) * 86400
							WHEN AmountTimeUnit = 'HOUR'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760) * 3600
							WHEN AmountTimeUnit = 'MINUTE'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760) * 60
							WHEN AmountTimeUnit = 'SECOND'
								THEN (CAST(Amount AS NUMERIC(20, 5)) * 8760)
							END
				ELSE 0
				END) / 3600 AS TimeSaving
	FROM (
		SELECT DISTINCT Cast(SUBSTRING(Completedate, 1, 8) + '01' AS DATE) AS DateSk
			,IdeaID
			,RecurringInterval
			,AmountTimeUnit
			,TypeName
			,Amount
		FROM [SrcKaiNexus].[itemList]
		WHERE Completedate IS NOT NULL AND Status ='COMPLETE'
			AND TypeName IN (
				'Time Reduction'
				,'Lead Time Reduction'
				)
		) Timesaved
	GROUP BY DateSk
	)
SELECT M.DATE
	,C.CompletedCount
	,S.SubmittedCount
	,C.ResultChangeCount
	,CAST((CAST(C.ResultChangeCount AS FLOAT) * 100) / CAST(C.CompletedCount AS FLOAT) AS DECIMAL(20, 2)) AS ResultChangePer
	,F.FinancialImpactTotal
	,T.TimeSaving
FROM rolling13months M
LEFT JOIN Submitted S ON M.DATE = S.DateSk
LEFT JOIN Completed C ON M.DATE = C.DateSk
LEFT JOIN Financial F ON M.DATE = F.DateSk
LEFT JOIN Timesaved T ON M.DATE = T.DateSk;