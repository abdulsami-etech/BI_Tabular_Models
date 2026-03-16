CREATE TABLE [SrcKafkaHeroku].[assets_outcome]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[_region] [varchar](32) NOT NULL,
	[_partition] [int] NOT NULL,
	[_offset] [bigint] NOT NULL,
	[_timestamp] [datetime2](7) NOT NULL,
	[asset_group_id] [varchar](36) NULL,
	[user_id] [varchar](36) NULL,
	[region] [nvarchar](50) NULL,
	[bucket_name] [nvarchar](50) NULL,
	[assets] [nvarchar](max) NULL
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