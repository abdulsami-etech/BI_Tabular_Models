--BI-12996 New Table
CREATE TABLE [DWSAP].[DimSalesDocumentAdTier_Performance]
(
	[ADLSTimestamp] [datetime2](7) NULL,
	[PartitionColumn] [varchar](25) NULL,
	[Sales Document] [nvarchar](10) NULL,
	[Document Date] [nvarchar](10) NULL,
	[Advantage Tier] [nvarchar](255) NULL,
	[Age Tier] [decimal](18, 0) NULL,
	[Professional Category] [nvarchar](50) NULL,
	[IsDSOOrder] [varchar](3) NULL,
	[RecordType] [nvarchar](15) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Sales Document] ),
	CLUSTERED COLUMNSTORE INDEX
)


