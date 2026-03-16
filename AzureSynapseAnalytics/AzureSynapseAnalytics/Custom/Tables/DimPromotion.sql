CREATE TABLE [Custom].[DimPromotion]
(	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NOT  NULL,
	[IncentiveID] [varchar](18) NOT NULL,
	[IncentiveNumber] [nvarchar](1300) NULL,
	[IncentiveCode] [nvarchar](255) NULL,
	[IncentiveName] [nvarchar](80) NULL,
	[IncentiveGroup] [nvarchar](80) NULL,
	[SAPPricingCondition] [nvarchar](255) NULL,
	[PromotionStartDate] [datetime2](7) NULL,
	[PromotionEndDate] [datetime2](7) NULL,
	[PromotionRegion] [nvarchar](max) NULL,
	[PromotionSubUseType] [nvarchar](255) NULL,
	[PromotionUseType] [nvarchar](255) NULL
)
WITH (CLUSTERED INDEX([IncentiveID]), DISTRIBUTION = REPLICATE);