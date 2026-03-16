CREATE TABLE [SrcWebStore].[spree_variants]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[sku] [nvarchar](256) NOT NULL,
	[weight] [decimal](8, 2) NULL,
	[height] [decimal](8, 2) NULL,
	[width] [decimal](8, 2) NULL,
	[depth] [decimal](8, 2) NULL,
	[deleted_at] [datetime2](6) NULL,
	[is_master] [bit] NULL,
	[product_id] [int] NULL,
	[cost_price] [decimal](10, 2) NULL,
	[position] [int] NULL,
	[cost_currency] [nvarchar](256) NULL,
	[track_inventory] [bit] NULL,
	[tax_category_id] [int] NULL,
	[updated_at] [datetime2](6) NOT NULL,
	[stock_items_count] [int] NOT NULL,
	[quantity_limit_rule] [int] NULL,
	[quantity_limit_y] [decimal](8, 2) NULL,
	[available] [bit] NULL,
	[download_only] [bit] NULL,
	[locale] [nvarchar](256) NULL,
	[type_of_material] [nvarchar](256) NULL,
	[owners] [nvarchar](256) NULL,
	[region] [nvarchar](256) NULL,
	[invisalign_go] [nvarchar](256) NULL,
	[backend_name] [nvarchar](256) NULL,
	[quantity_limit_x] [decimal](8, 2) NULL,
	[unit_of_measure] [nvarchar](256) NULL,
	[is_itero] [bit] NULL,
	[quantity_limit_y_dso] [decimal](8, 2) NULL,
	[expiration_date] [datetime2](6) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)