CREATE TABLE [SrcEloomi].[categories]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[name] [nvarchar](100) NULL,
	[parent_id] [int] NULL,
	[type] [nvarchar](100) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
)
GO