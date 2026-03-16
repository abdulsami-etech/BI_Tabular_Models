CREATE TABLE [DWIRIS].[DimServiceContract]
(
	[SKServiceContract] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](80) NOT NULL,
	[KeyServiceContract] [nvarchar](80) NULL,
	[KeyAccount] [nchar](72) NULL,
	[KeyAsset] [nvarchar](320) NULL,
	[LineItemNumber] [nvarchar](1020) NULL,
	[KeyProduct] [nvarchar](510) NULL,
	[Quantity] [decimal](18,2) NULL,
	[ContractNumber] [nvarchar](120) NULL,
	[Discount] [decimal](18,2) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[GrandTotal] [decimal](18,2) NULL,
	[Name] [nvarchar](1020) NULL,
	[ParentServiceContractId] [nchar](72) NULL,
	[ScannerSerialNumber] [nvarchar](400) NULL,
	[ShipToAccount] [nchar](72) NULL,
	[ShippingHandling] [decimal](18,2) NULL,
	[Status] [nvarchar](1020) NULL,
	[SubTotal] [decimal](18,2) NULL,
	[Tax] [decimal](18,2) NULL,
	[Term] [int] NULL,
	[TotalPrice] [decimal](18,2) NULL,
	[Type] [nvarchar](128) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[SKServiceContract] ASC
	)
)