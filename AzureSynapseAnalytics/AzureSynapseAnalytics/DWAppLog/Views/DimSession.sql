CREATE VIEW [DWAppLog].[DimSession] AS Select 
		HS.SKSession,
		HS.KeyTrace,
		HS.KeyTs,
        TRY_CONVERT(datetimeoffset,ss.event_ts ) as SessionStart,
		ss.event_version,
		ss.event_browser_userAgent,
		ss.event_browser_devicePixelRatio,
		ss.event_browser_isTouchDevice,
		ss.event_browser_language,
        ss.event_browser_name,
		COALESCE(c.ClinID,'-1') as Clinician_ID,
        COALESCE(c.SKContact,-1) as SKContact,
        ss.event_browser_viewPortWidth,
        ss.event_browser_viewPortHeight,
        COALESCE(ss.event_browser_viewPortWidth,'Unknown') + ':' + COALESCE(ss.event_browser_viewPortHeight,'Unknown')  as Resolution,
        SUBSTRING(ss.event_date,29,3) + ':' + SUBSTRING(ss.event_date,32,2) as OriginalOffset,
		COALESCE(ss.SAPOrderNumber,-1) as SAPOrderNumber,
		COALESCE(ss.SKOrder,-1) as SKOrder,
        COALESCE(sc.DurationSecond,0) as SessionDurationInSeconds,
        COALESCE(ss.flow,'pro') as flow,
        ss.ccid,
		COALESCE(sc._3DControls,0) as Used3DControls,
		COALESCE(sc.CCMod,0) as CCMod,
		COALESCE(sc.CCA,0) as CCA,
		COALESCE(sc.IFVModification,0) as IFVModification,
		COALESCE(sc.IFVReview,0) as IFVReview,
		COALESCE(ss.Is2MinCC,0) as Is2MinCC
	from [DWAppLog].[HubSession] HS
    LEFT JOIN [DWAppLog].[SatSessionCCProCloud] ss on ss.SKSession=HS.SKSession
	LEFT JOIN [DWAppLog].[SatSessionCount] sc on sc.SKSession=HS.SKSession
    LEFT JOIN [DW].[DimContact] c on c.ClinID=ss.event_user;