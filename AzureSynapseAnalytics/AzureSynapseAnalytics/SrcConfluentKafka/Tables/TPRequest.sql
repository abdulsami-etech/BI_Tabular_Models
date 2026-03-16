CREATE TABLE [SrcConfluentKafka].[TPRequest]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Timestamp] [bigint] NOT NULL,
	[Topic] [nvarchar](250) NOT NULL,
	[Partition] [int] NOT NULL,
	[Offset] [bigint] NOT NULL,
	[MessageValue] [varchar](4000) NULL,
	[MessageHeaders] [varchar](4000) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Timestamp] ),
	CLUSTERED INDEX
	(
		[Offset] ASC,
		[Partition] ASC
	)
)
