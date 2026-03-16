CREATE TABLE [SrcKafkaHeroku].[notifications_event]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[_region] [varchar](32) NOT NULL,
	[_partition] [int] NOT NULL,
	[_offset] [bigint] NOT NULL,
	[_timestamp] [datetime2](7) NOT NULL,
	[event_name] [varchar](256) NULL,
	[uuid] [varchar](36) NULL,
	[notification_type] [varchar](256) NULL,
	[message_type] [varchar](256) NULL,
	[patient_id] [varchar](256) NULL,
	[clin_id] [varchar](256) NULL,
	[created_date] [varchar](256) NULL,
	[app_name] [varchar](256) NULL,
	[app_version] [varchar](32) NULL,
	[api_type] [varchar](256) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO