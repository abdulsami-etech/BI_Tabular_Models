CREATE TABLE [SrcKafkaHeroku].[user_profile_event]
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
	[lead_id] [varchar](256) NULL,
	[device] [varchar](256) NULL,
	[clin_id] [varchar](256) NULL,
	[country] [varchar](256) NULL,
	[user_type] [varchar](256) NULL,
	[product_name] [varchar](256) NULL,
	[mailing_country] [varchar](256) NULL,
	[remote_care_invite_status] [varchar](256) NULL,
	[remote_care_accept_terms] [varchar](256) NULL,
	[treatment_start_date] [varchar](32) NULL,
	[number_lower_aligners] [varchar](256) NULL,
	[vip_patient_id] [varchar](64) NULL,
	[is_app_user] [bit] NULL,
	[is_demo] [bit] NULL,
	[app_name] [varchar](256) NULL,
	[app_version] [varchar](32) NULL,
	[api_type] [varchar](256) NULL,
	[created_date] [varchar](32) NULL,
	[updated_date] [varchar](32) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
GO