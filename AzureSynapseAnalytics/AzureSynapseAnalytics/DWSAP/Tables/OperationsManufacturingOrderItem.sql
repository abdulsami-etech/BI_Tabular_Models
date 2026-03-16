CREATE TABLE [DWSAP].[OperationsManufacturingOrderItem]
(
	[Sales Document] [bigint] NULL,
	[Sales Document Item Number] [int] NULL,
	[Mfg Order Actual End Date] [date] NULL,
	[DatPrpPlant] [nvarchar](15) NULL,
	[OrdAdqPlant] [nvarchar](15) NULL,
	[TreatMPlant] [nvarchar](15) NULL,
	[DDTPlant] [nvarchar](15) NULL,
	[Manufacturing Order] [bigint] NULL,
	[Mfg Material Number] [nvarchar](36) NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Status] [nvarchar](40) NULL,
	[Data Prep Plant Name] [nvarchar](30) NULL,
	[Order Acquisition Plant Name] [nvarchar](30) NULL,
	[Treatment Plant Name] [nvarchar](30) NULL,
	[DDT Plant Name] [nvarchar](30) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Sales Document] ),
	CLUSTERED COLUMNSTORE INDEX
)