CREATE VIEW [TABTOPS].[FactAgingDDT]
AS 
WITH DDT_Completions AS
(
SELECT 
	FLH.[LotKey],
	FLH.[LotHistoryKey],
	FLH.[WorkOrderNumber],
	FLH.[CaseStartDateTime]																AS [DDT_StartTime],
	FLH.[CaseCompleteDateTime]															AS [DDT_CompleteTime],
	FLH.[SKCompleteDate]																AS [SK_CompleteDate],
    --max(FLH.[CompleteCount]) OVER (PARTITION BY FLH.[WorkOrderNumber], FLH.[LotKey])	AS [MaxCompletionCount],
	FLH.[CompleteCount]	AS [MaxCompletionCount],
	CASE WHEN FLH.[PostClinCheckFail] = 0 THEN 'No' ELSE 'Yes'END 						AS [IsCCMod],
	datename(WEEKDAY,FLH.[CaseCompleteDateTime])										AS [DayofWeek],
	DATEDIFF(minute,FLH.[CaseStartDateTime],FLH.[CaseCompleteDateTime])					AS [CycleTime DDT (Min)]

FROM [TABTOPS].[FactLotHistory]	FLH
	INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
	INNER JOIN [TABTOPS].[FactLotCurrent]    FLC	ON FLC.[LotKey] = FLH.[LotKey]
	INNER JOIN [TABTOPS].[DimCompleteReason] CR		ON CR.[SKCompleteReason] = FLH.[SKCompleteReason]
	INNER JOIN (SELECT 
					FLH.[LotKey],
					FLH.[LotHistoryKey],
					FLH.[WorkOrderNumber],
					max(FLH.[CompleteCount]) OVER (PARTITION BY FLH.[WorkOrderNumber], FLH.[LotKey])	AS [MaxCompletionCount]

				FROM [TABTOPS].[FactLotHistory]	FLH
					INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
					INNER JOIN [TABTOPS].[FactLotCurrent]    FLC	ON FLC.[LotKey] = FLH.[LotKey]
					INNER JOIN [TABTOPS].[DimCompleteReason] CR		ON CR.[SKCompleteReason] = FLH.[SKCompleteReason]
					LEFT JOIN (	SELECT 
									FLH.[LotKey],
									FLH.[LotHistoryKey],
									FLH.[WorkOrderNumber],
									max(FLH.[CaseCompleteDateTime]) OVER (PARTITION BY FLH.[WorkOrderNumber], FLH.[LotKey])	AS [MaxCaseCompleteDateTime]

								FROM [TABTOPS].[FactLotHistory]	FLH
									INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
									INNER JOIN [TABTOPS].[FactLotCurrent]    FLC	ON FLC.[LotKey] = FLH.[LotKey]
									INNER JOIN [TABTOPS].[DimCompleteReason] CR		ON CR.[SKCompleteReason] = FLH.[SKCompleteReason]

								WHERE 
									OPS.[OperationName] IN ('ClinCheck')
									and
									FLH.[CompleteCount] = 1
									AND
									CR.[CompleteReason] != 'OK') MAXCC ON MAXCC.LotKey = FLC.LotKey


				WHERE 
	
					OPS.[OperationName] IN ('DDT Bite0')
					AND
					CR.[IsCompletion] = 'Yes'
					AND
					FLH.CaseCompleteDateTime <= MAXCC.MaxCaseCompleteDateTime
					AND
					FLH.[PostClinCheckFail] = 0) MAXX ON MAXX.[LotHistoryKey] = FLH.[LotHistoryKey]


WHERE 
	
	OPS.[OperationName] IN ('DDT Bite0')
	AND
	CR.[IsCompletion] = 'Yes'
	AND
	FLH.[PostClinCheckFail] = 0
	AND (FLH.[CompleteCount] = MAXX.[MaxCompletionCount] AND FLH.[LotHistoryKey] = MAXX.[LotHistoryKey])

)
, Tagging AS
(
-- Get Tagging Ops from LotKey on DDT Completions
SELECT 
	FLH.[LotKey],
	FLH.[WorkOrderNumber],
	MIN(FLH.[CaseStartDateTime]) OVER  (PARTITION BY DDT.[WorkOrderNumber],FLH.[LotKey])			AS [Tagging_StartTime]

FROM [TABTOPS].[FactLotHistory]	FLH
	INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
	INNER JOIN DDT_Completions DDT ON   DDT.[LotKey] = FLH.[LotKey] 


WHERE
	OPS.[OperationName] IN ('Tagging')
	--AND
	--FLH.[CompleteCount] = 1
)
, Hold AS
(
-- Get MP and CH from DDT Completion LotKey
SELECT 
	FLH.[LotKey],
	FLH.[WorkOrderNumber],
	[MP_minutes] = SUM(CASE WHEN OPS.[OperationName] = 'Materials Pending' AND DDT.[DDT_CompleteTime] > FLH.[CaseCompleteDateTime] THEN ISNULL(DATEDIFF(MINUTE, FLH.[CaseStartDateTime], FLH.[CaseCompleteDateTime]), 0) ELSE 0 END),
	[CH_minutes] = SUM(CASE WHEN OPS.[OperationName] IN ('Clinical Hold', 'CR Incoming Hold', 'CCMod Hold') AND DDT.[DDT_CompleteTime] > FLH.[CaseCompleteDateTime]  THEN ISNULL(DATEDIFF(MINUTE, FLH.[CaseStartDateTime], FLH.[CaseCompleteDateTime]), 0) ELSE 0 END)

FROM [TABTOPS].[FactLotHistory]	FLH
	INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
	INNER JOIN DDT_Completions DDT ON  DDT.[LotKey] = FLH.[LotKey] 

WHERE
	OPS.[OperationName] IN ('Materials Pending', 'Clinical Hold', 'CR Incoming Hold', 'CCMod Hold')
GROUP BY
	FLH.[LotKey],
	FLH.[WorkOrderNumber]
)
, Weekends AS
(
-- Get Weekend Time
SELECT 
	FLH.[LotKey],
	FLH.[WorkOrderNumber],
	[WK_minutes] = SUM(ISNULL(DATEDIFF(MINUTE, FLH.[CaseStartDateTime], FLH.[CaseCompleteDateTime]), 0))


FROM [TABTOPS].[FactLotHistory]	FLH
	INNER JOIN [TABTOPS].[DimOperation]		 OPS	ON OPS.[SKOperation] = FLH.[SKOperation]
	INNER JOIN DDT_Completions DDT ON  DDT.[WorkOrderNumber] = FLH.[WorkOrderNumber] 

WHERE
	OPS.[OperationName] NOT IN ('Materials Pending', 
								'Clinical Hold', 
								'CR Incoming Hold', 
								'CCMod Hold',
								'DDT Bite0',
								'ClinCheck',
								'Setup & Stage',
								'ePub',
								'Treat File Upload',
								'Setup Product Change',
								'Treat',
								'ePub Rework',
								'Treat File Upload Hold')
	AND
	FLH.[CompleteCount] = 1
	AND
	datename(WEEKDAY,FLH.[CaseCompleteDateTime]) IN ('Sunday','Saturday')
GROUP BY
	FLH.[LotKey],
	FLH.[WorkOrderNumber]
)
-- Final Table

SELECT 
	DDT.LotKey,
	DDT.LotHistoryKey,
	DDT.WorkOrderNumber,
	DDT.[SK_CompleteDate],
	T.[Tagging_StartTime],
	DDT.DDT_CompleteTime,
	[MP Time (Hrs)] = ISNULL(H.[MP_minutes]/60.00,0),
	[Hold Time (Hrs)] = ISNULL(H.[CH_minutes]/60.00,0),
	[Weekend Time] = ISNULL(W.[WK_minutes]/60.00,0),
	(DATEDIFF(minute,T.[Tagging_StartTime],DDT.[DDT_CompleteTime]) - ISNULL(H.[MP_minutes]+[CH_minutes],0))/60.00	AS [Aging Time DDT (Hrs)],
	(DATEDIFF(minute,T.[Tagging_StartTime],DDT.[DDT_CompleteTime]) - ISNULL(H.[MP_minutes]+[CH_minutes],0))/60.00 - ISNULL(W.[WK_minutes]/60.00,0)	AS [Aging Time DDT Poland (Hrs)]
FROM DDT_Completions DDT
	INNER JOIN Tagging T ON T.[LotKey] = DDT.[LotKey] AND T.[WorkOrderNumber] = DDT.[WorkOrderNumber]
	INNER JOIN Hold H ON H.[LotKey] = DDT.[LotKey] AND H.[WorkOrderNumber] = DDT.[WorkOrderNumber]
	LEFT JOIN Weekends W ON W.[LotKey] = DDT.[LotKey] AND W.[WorkOrderNumber] = DDT.[WorkOrderNumber];
GO
