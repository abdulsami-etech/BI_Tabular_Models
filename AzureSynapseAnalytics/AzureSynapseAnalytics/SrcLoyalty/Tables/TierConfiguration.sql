
CREATE TABLE [SrcLoyalty].[TierConfiguration]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[TierName] [varchar](50) NOT NULL,
	[Channel] [varchar](10) NOT NULL,
	[EffectiveDateFrom] [date] NOT NULL,
	[EffectiveDateTo] [date] NOT NULL,
	[TierOrder] [int] NOT NULL,
	[LowPoints] [int] NOT NULL,
	[HighPoints] [int] NOT NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)



