CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_Setting]
AS SELECT
		trace,
		action,
		ts,
		_count,
		splunk_time,
		appVersion,
		colorScheme,
		includeBiteCorrection,
		occlusionColors,
		performance,
		rotationMode,
		transparencyTeeth,
		attachmentColor_colorName,
		attachmentColor_value,
		backgroundColor_colorName,
		backgroundColor_value
	FROM SrcSplunk.CCCloud_Setting;