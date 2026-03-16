CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_PowerTools]
AS SELECT
	[trace]
	,[action]
	,[ts]
	,[_count]
	,[splunk_time]
	,[appVersion]
	,[_data]
    ,CASE WHEN JSON_QUERY([_data],'$.sagittalAPCorrection') IS NOT NULL THEN 1 ELSE 0 END as sagittalAPCorrection
    ,CASE WHEN JSON_QUERY([_data],'$.extractions') IS NOT NULL THEN 1 ELSE 0 END as extractions
    ,CASE WHEN JSON_QUERY([_data],'$.IPR') IS NOT NULL THEN 1 ELSE 0 END as IPR
FROM [SrcSplunk].[CCCloud_PowerTools]
WHERE ISJSON([_data])=1
