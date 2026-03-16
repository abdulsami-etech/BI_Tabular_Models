CREATE TABLE [SrcMESCorp].[DC_at_TreatmentHistory]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[dc_instance_key] [bigint] NOT NULL,
	[site_num] [int] NULL,
	[creation_time_u] [datetime] NULL,
	[last_modified_time_u] [datetime] NULL,
	[op_name] [nvarchar](50) NULL,
	[user_name] [nvarchar](100) NULL,
	[object_key] [bigint] NULL,
	[object_name] [nvarchar](50) NULL,
	[current_treatment_flow] [nvarchar](50) NULL,
	[new_treatment_flow] [nvarchar](50) NULL,
	[type] [nvarchar](50) NULL,
	[current_value] [nvarchar](50) NULL,
	[new_value] [nvarchar](50) NULL
)
WITH ( CLUSTERED COLUMNSTORE INDEX,	DISTRIBUTION = HASH ( [dc_instance_key] ));