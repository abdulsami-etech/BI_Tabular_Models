CREATE TABLE [SrcKafkaHeroku].[remote_care_web_event]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[_region] [varchar](32) NOT NULL,
	[_partition] [int] NOT NULL,
	[_offset] [bigint] NOT NULL,
	[_timestamp] [datetime2](7) NOT NULL,
	[event_name] [varchar](256) NULL,
	[event_category] [varchar](256) NULL,
	[event_action] [varchar](256) NULL,
	[clin_id] [varchar](256) NULL,
	[patient_id] [varchar](256) NULL,
	[lead_id] [varchar](256) NULL,
	[status] [varchar](256) NULL,
	[app_name] [varchar](256) NULL,
	[app_version] [varchar](256) NULL,
	[api_type] [varchar](256) NULL,
	[country_code] [varchar](256) NULL,
	[created_at] [varchar](256) NULL,
	[event_meta_data] [nvarchar](MAX) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[_region] ASC,
		[_partition] ASC,
		[_offset] ASC
	)
)