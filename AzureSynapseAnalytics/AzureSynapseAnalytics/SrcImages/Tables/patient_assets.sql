CREATE TABLE [SrcImages].[patient_assets]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [nvarchar](255) NOT NULL,
	[creation_date] [datetime] NULL,
	[patient] [nvarchar](255) NULL,
	[deleted] [int] NULL,
	[asset_role_id] [int] NULL,
	[asset_type_id] [int] NULL,
	[loaded] [int] NULL,
	[metadata] [nvarchar](4000) NULL,
	[owner_clinid] [nvarchar](255) NULL,
	[source] [nvarchar](50) NULL,
	[auto2d3dIntegrationStatus] [nvarchar](50) NULL,
	[ffResult] [nvarchar](50) NULL,
	[order_id] [nvarchar](50) NULL,
	[sourceImagesAssetId] [nvarchar](50) NULL,
	[ColorScan] [nvarchar](50) NULL,
	[iTeroOrderID] [nvarchar](50) NULL,
	[photoSetpurpose] [nvarchar](50) NULL,
	[replacedImagesAssetId] [nvarchar](50) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)