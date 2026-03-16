CREATE TABLE [DWSAP].[DimCOPARevenueValueType]
(
	[SKValueType] [int] NOT NULL,
	[Valuefield] [varchar](5) NOT NULL,
	[Valuetype] [varchar](20) NOT NULL,
	[Valuetype2] [varchar](18) NOT NULL,
	[CreatedDate] [datetime] NOT NULL,
	[ModifiedDate] [datetime] NOT NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
);