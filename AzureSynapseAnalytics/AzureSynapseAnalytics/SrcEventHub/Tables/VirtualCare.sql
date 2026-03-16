CREATE TABLE [SrcEventHub].[VirtualCare]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[uuid] [nvarchar](50) NOT NULL,
	[event_type] [nvarchar](250) NULL,
	[kind] [nvarchar](50) NULL,
	[event_name] [nvarchar](250) NULL,
	[number_of_occurrences] [nvarchar](50) NULL,
	[created_date] [nvarchar](50) NULL,
	[asset_type] [nvarchar](50) NULL,
	[patient_id] [nvarchar](50) NULL,
	[user_type] [nvarchar](50) NULL,
	[lead_id] [nvarchar](50) NULL,
	[device] [nvarchar](4000) NULL,
	[clin_id] [nvarchar](300) NULL,
	[country] [nvarchar](50) NULL,
	[mailing_country] [nvarchar](50) NULL,
	[remote_care_invite_status] [nvarchar](50) NULL,
	[remote_care_accept_terms] [nvarchar](50) NULL,
	[treatment_start_date] [nvarchar](50) NULL,
	[number_lower_aligners] [nvarchar](50) NULL,
	[notification_type] [nvarchar](50) NULL,
	[message_type] [nvarchar](50) NULL,
	[description] [nvarchar](500) NULL,
	[app_name] [nvarchar](300) NULL,
	[app_version] [nvarchar](50) NULL,
	[api_type] [nvarchar](50) NULL,
	[asset_group_id] [nvarchar](50) NULL,
	[country_code] [nvarchar](300) NULL,
	[event_action] [nvarchar](400) NULL,
	[event_category] [nvarchar](200) NULL,
	[event_date] [nvarchar](50) NULL,
	[group_id] [nvarchar](50) NULL,
	[created_at] [nvarchar](50) NULL,
	[event_meta_data] [nvarchar](max) NULL,
	[is_app_user] [nvarchar](10) NULL,
	[is_demo] [nvarchar](10) NULL,
	[product_name] [nvarchar](100) NULL,
	[updated_date] [nvarchar](50) NULL,
	[DWHash] [char](40) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
);

