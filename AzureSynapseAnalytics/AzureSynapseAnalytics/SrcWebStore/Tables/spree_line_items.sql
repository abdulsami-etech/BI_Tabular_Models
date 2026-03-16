CREATE TABLE [SrcWebStore].[spree_line_items]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[variant_id] [int] NULL,
	[order_id] [int] NULL,
	[quantity] [int] NOT NULL,
	[price] [decimal](10, 2) NOT NULL,
	[created_at] [datetime2](6) NOT NULL,
	[updated_at] [datetime2](6) NOT NULL,
	[currency] [nvarchar](256) NULL,
	[cost_price] [decimal](10, 2) NULL,
	[tax_category_id] [int] NULL,
	[adjustment_total] [decimal](10, 2) NULL,
	[additional_tax_total] [decimal](10, 2) NULL,
	[promo_total] [decimal](10, 2) NULL,
	[included_tax_total] [decimal](10, 2) NOT NULL,
	[pre_tax_amount] [decimal](8, 2) NOT NULL,
	[checked] [bit] NULL,
	[points] [int] NULL,
	[selling_price] [decimal](8, 2) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED COLUMNSTORE INDEX
)


