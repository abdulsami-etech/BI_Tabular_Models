CREATE VIEW [DWAppLog].[FactSessionEvent]
AS SELECT
		LSE.SKSession,
		LSE.SKEvent,
		CONVERT(date,LSE.EventDate AT TIME ZONE 'UTC') AS EventDate,
		LSE.EventCount  ,
		LSE.SourceSystemCode,
		COALESCE(c.ClinID,'-1') as Clinician_ID,
        COALESCE(c.SKContact,-1) as SKContact,
        COALESCE(ss.SAPOrderNumber,-1) as SAPOrderNumber
	FROM [DWAppLog].[LinkSessionEvent] LSE
	LEFT JOIN [DWAppLog].[SatSessionCCProCloud] SS on SS.SKSession=LSE.SKSession
	LEFT JOIN [DW].[DimContact] c on c.ClinID=SS.event_user;