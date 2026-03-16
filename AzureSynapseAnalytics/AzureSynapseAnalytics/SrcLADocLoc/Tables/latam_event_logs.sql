CREATE TABLE [SrcLADocLoc].[latam_event_logs]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [bigint] NOT NULL,
	[log_type] [nvarchar](255) NULL,
	[implementation_type] [nvarchar](255) NULL,
	[search_type] [nvarchar](255) NULL,
	[search_source] [nvarchar](255) NULL,
	[search_duration] [int] NULL,
	[search_name] [nvarchar](255) NULL,
	[search_address] [nvarchar](255) NULL,
	[search_postal_code] [nvarchar](255) NULL,
	[search_city] [nvarchar](255) NULL,
	[search_state] [nvarchar](255) NULL,
	[search_country] [nvarchar](255) NULL,
	[search_filter] [nvarchar](255) NULL,
	[search_sort] [nvarchar](255) NULL,
	[search_results] [int] NULL,
	[search_status] [int] NULL,
	[search_session_id] [nvarchar](255) NULL,
	[search_context_id] [nvarchar](255) NULL,
	[search_radius] [decimal](18, 0) NULL,
	[search_end_position] [int] NULL,
	[primary_doc_id] [nvarchar](255) NULL,
	[docid_list] [nvarchar](max) NULL,
	[client_ip] [nvarchar](255) NULL,
	[viewer_id] [nvarchar](255) NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
)


