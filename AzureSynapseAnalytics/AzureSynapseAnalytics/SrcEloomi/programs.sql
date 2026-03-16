CREATE TABLE [SrcEloomi].[programs]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NULL,
	[id] [bigint] NULL,
	[name] [nvarchar](1000) NULL,
	[description] [nvarchar](max) NULL,
	[created_at] [datetime2](7) NULL,
	[updated_at] [datetime2](7) NULL
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