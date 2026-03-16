CREATE VIEW [DWAppLog].[CCCloudLog_Splunk_MoveAttachment]
AS SELECT
			trace,
			action,
			ts,
			_count,
			splunk_time,
			appVersion,
			attachmentId,
			movementType
	FROM SrcSplunk.CCCloud_MoveAttachment;