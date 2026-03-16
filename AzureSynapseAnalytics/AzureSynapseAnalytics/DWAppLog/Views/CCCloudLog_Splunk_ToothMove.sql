CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_ToothMove]
AS SELECT
		trace,
		action,
		ts,
		_count,
		splunk_time,
		appVersion,
		performedBy,
		teeth,
		type,
		_value,
		widgetType
	FROM SrcSplunk.CCCloud_ToothMove;