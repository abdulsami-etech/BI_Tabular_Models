CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_3DMod]
AS SELECT
		action,
		trace,
		ts,
		_count,
		_all,
		_type,
		_value,
		appVersion,
		attachments,
		cuts,
		fipos,
		kind,
		newSize,
		occplanangle,
		placingType,
		splunk_time,
		surface,
		tooth,
		toothId,
		way
	FROM SrcSplunk.CCCloud_3DMod;