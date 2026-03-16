CREATE TABLE [SrcCONSDL].[ConsdlCountryToRegionMapping]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Region] [nvarchar](100) NOT NULL,
	[Country_RollUp] [nvarchar](200) NOT NULL,
	[Country] [nvarchar](200) NOT NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)


