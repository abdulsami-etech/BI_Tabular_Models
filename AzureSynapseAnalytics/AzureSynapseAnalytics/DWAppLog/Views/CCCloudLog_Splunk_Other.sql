CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_Other]
AS SELECT
		trace,
		action,
		ts,
		_count,
		splunk_time,
		appVersion,
		isFromKeyboard,
		isSuperimpositionShown,
		mode,
		planId
	FROM SrcSplunk.CCCloud_Other;