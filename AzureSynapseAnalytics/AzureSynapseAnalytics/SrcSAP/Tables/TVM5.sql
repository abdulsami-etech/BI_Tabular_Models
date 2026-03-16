CREATE TABLE [SrcSAP].[TVM5]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[MANDT] [nvarchar](20) NULL,
	[MVGR5] [nvarchar](20) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [MANDT] ),
	CLUSTERED COLUMNSTORE INDEX
)


