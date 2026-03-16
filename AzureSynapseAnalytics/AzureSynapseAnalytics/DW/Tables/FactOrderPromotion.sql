CREATE TABLE [DW].[FactOrderPromotion]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NULL,
	[SFDCOrderAdjustmentLineItemID] [nchar](18) NOT NULL,
	[SKPromotion] [bigint] NOT NULL,
	[SKOrder] [bigint] NOT NULL,
	[KeyOrder] [nvarchar](255) NULL,
	[IncentiveId] [nchar](18) NULL,
	[IncentiveCode] [nvarchar](255) NULL,
	[CurrencyCode] [nvarchar](3) NOT NULL,
	[DiscountAmount] [decimal](18, 2) NULL,
	[DiscPercent] [decimal](18, 2) NULL,
	[CouponCode] [nvarchar](6) NULL,
	[SecRegion] [varchar](10) NULL
 CONSTRAINT [PK_FactOrderPromotion] PRIMARY KEY NONCLUSTERED 
	(
		[SKPromotion] ASC
	) NOT ENFORCED 
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
)
