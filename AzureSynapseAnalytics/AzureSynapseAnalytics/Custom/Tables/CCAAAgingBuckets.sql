CREATE TABLE [Custom].[CCAAAgingBuckets](
	[CCAAAgeingDetailKey] [int] NOT NULL,
	[RangeBegin] [int] NULL,
	[RangeEnd] [int] NULL,
	[CCAAAgeingDetail] [nvarchar](50) NULL,
	[CCAAAgeing] [nvarchar](50) NULL
)
WITH (CLUSTERED INDEX([CCAAAgeingDetailKey]), DISTRIBUTION = REPLICATE);
