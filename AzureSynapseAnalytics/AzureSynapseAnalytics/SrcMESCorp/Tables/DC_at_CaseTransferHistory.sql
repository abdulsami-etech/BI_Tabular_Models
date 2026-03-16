CREATE TABLE [SrcMESCorp].[DC_at_CaseTransferHistory]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[dc_instance_key] [bigint] NOT NULL,
	[site_num] [int] NOT NULL,
	[route_name] [nvarchar](64) NULL,
	[op_name] [nvarchar](64) NULL,
	[user_name] [nvarchar](64) NULL,
	[object_key] [bigint] NOT NULL,
	[object_name] [nvarchar](128) NULL,
	[object_type] [nvarchar](64) NOT NULL,
	[source_plant] [nvarchar](64) NULL,
	[source_region] [nvarchar](64) NULL,
	[target_plant] [nvarchar](64) NULL,
	[target_region] [nvarchar](64) NULL,
	[is_finished] [tinyint] NULL,
	[creation_time] [datetime] NOT NULL,
	[creation_time_u] [datetime] NULL,
	[last_modified_time] [datetime] NULL,
	[last_modified_time_u] [datetime] NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([object_key]));