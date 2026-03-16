CREATE TABLE [SrcMESCorpNRT].[WORK_ORDER]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[order_key] [bigint] NOT NULL,
	[site_num] [int] NOT NULL,
	[order_number] [nvarchar](64) NOT NULL,
	[entered_time] [datetime] NULL,
	[promised_time] [datetime] NULL,
	[finished_time] [datetime] NULL,
	[order_state] [nvarchar](64) NULL,
	[order_close_type] [nvarchar](50) NOT NULL,
	[tobj_status_key] [bigint] NOT NULL,
	[category] [nvarchar](50) NULL,
	[entered_time_u] [datetime] NULL,
	[promised_time_u] [datetime] NULL,
	[finished_time_u] [datetime] NULL,
	[last_modified_time_u] [datetime] NULL
)
WITH
(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH ( [order_key] ));