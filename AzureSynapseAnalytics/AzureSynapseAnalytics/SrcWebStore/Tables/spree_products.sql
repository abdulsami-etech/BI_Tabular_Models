CREATE TABLE [SrcWebStore].[spree_products]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[name] [nvarchar](256) NOT NULL,
	[description] [nvarchar](4000) NULL,
	[available_on] [datetime2](6) NULL,
	[deleted_at] [datetime2](6) NULL,
	[slug] [nvarchar](256) NULL,
	[tax_category_id] [int] NULL,
	[shipping_category_id] [int] NULL,
	[created_at] [datetime2](6) NOT NULL,
	[updated_at] [datetime2](6) NOT NULL,
	[promotionable] [bit] NULL,
	[popup_warning] [nvarchar](512) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)