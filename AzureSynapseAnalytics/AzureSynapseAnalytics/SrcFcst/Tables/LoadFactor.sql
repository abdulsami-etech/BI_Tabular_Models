CREATE TABLE [SrcFcst].[LoadFactor]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Measure] [varchar](100) NOT NULL,
	[Date] [date] NOT NULL,
	[LoadFactor] [decimal](17, 9) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)


