CREATE TABLE [SrcEloomi].[courses]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [bigint] NOT NULL,
	[name] [nvarchar](1000) NULL,
	[description] [nvarchar](max) NULL,
	[description_extended] [nvarchar](max) NULL,
	[course_type] [nvarchar](100) NULL,
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
