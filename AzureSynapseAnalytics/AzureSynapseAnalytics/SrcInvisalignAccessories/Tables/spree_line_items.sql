CREATE TABLE [SrcInvisalignAccessories].[spree_line_items] (
    [LZBatchID]                    INT             NOT NULL,
    [ADLSBatchID]                  INT             NOT NULL,
    [ADLSTimestamp]                DATETIME2 (0)   NOT NULL,
    [id]                           INT             NOT NULL,
    [variant_id]                   INT             NULL,
    [order_id]                     INT             NULL,
    [quantity]                     INT             NOT NULL,
    [price]                        NUMERIC (10, 2) NOT NULL,
    [created_at]                   DATETIME2 (7)   NOT NULL,
    [updated_at]                   DATETIME2 (7)   NOT NULL,
    [currency]                     NVARCHAR (256)  NULL,
    [cost_price]                   NUMERIC (10, 2) NULL,
    [tax_category_id]              INT             NULL,
    [adjustment_total]             NUMERIC (10, 2) NULL,
    [additional_tax_total]         NUMERIC (10, 2) NULL,
    [promo_total]                  NUMERIC (10, 2) NULL,
    [included_tax_total]           NUMERIC (10, 2) NOT NULL,
    [pre_tax_amount]               NUMERIC (12, 4) NOT NULL,
    [taxable_adjustment_total]     NUMERIC (10, 2) NOT NULL,
    [non_taxable_adjustment_total] NUMERIC (10, 2) NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

