CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_FeatureSmall]
AS SELECT
			trace,
			action,
			ts,
			_count,
			splunk_time,
			appVersion
	FROM SrcSplunk.CCCloud_FeatureSmall;