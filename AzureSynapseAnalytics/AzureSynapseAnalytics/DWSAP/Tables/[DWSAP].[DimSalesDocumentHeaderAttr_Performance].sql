--BI-12996 New Table
CREATE TABLE [DWSAP].[DimSalesDocumentHeaderAttr_Performance]
(
	[ADLSTimestamp] [datetime2](7) NULL,
	[PartitionColumn] [varchar](25) NULL,
	[Sales Document] [nvarchar](10) NULL,
	[TreatingDoctor] [nvarchar](1300) NULL,
	[ShipTo] [nvarchar](4000) NULL,
	[TreatmentLocation] [nvarchar](1300) NULL,
	[Is IO Scan] [varchar](3) NULL,
	[Document Date] [nvarchar](10) NULL,
	[Advantage Tier] [nvarchar](255) NULL,
	[Align Retail] [nvarchar](10) NULL,
	[Employee Responsible] [nvarchar](10) NULL,
	[Financial Contact] [nvarchar](10) NULL,
	[Junior Doctor] [nvarchar](10) NULL,
	[Submitting Student] [nvarchar](10) NULL,
	[Territory Manager] [nvarchar](10) NULL,
	[Bill-to party text] [nvarchar](255) NULL,
	[ShipTo Text] [nvarchar](255) NULL,
	[SoldTo Text] [nvarchar](255) NULL,
	[ProductType] [nvarchar](100) NULL,
	[AMR Date COPA] [char](8) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Sales Document] ),
	CLUSTERED COLUMNSTORE INDEX
)



