CREATE TABLE [SrcInvisalignAccessories].[spree_variants] (
    [LZBatchID]                INT             NOT NULL,
    [ADLSBatchID]              INT             NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)   NOT NULL,
    [id]                       INT             NOT NULL,
    [sku]                      NVARCHAR (256)  NOT NULL,
    [weight]                   NUMERIC (8, 2)  NULL,
    [height]                   NUMERIC (8, 2)  NULL,
    [width]                    NUMERIC (8, 2)  NULL,
    [depth]                    NUMERIC (8, 2)  NULL,
    [deleted_at]               DATETIME2 (7)   NULL,
    [is_master]                BIT             NULL,
    [product_id]               INT             NULL,
    [cost_price]               NUMERIC (10, 2) NULL,
    [position]                 INT             NULL,
    [cost_currency]            NVARCHAR (256)  NULL,
    [track_inventory]          BIT             NULL,
    [tax_category_id]          INT             NULL,
    [updated_at]               DATETIME2 (7)   NOT NULL,
    [discontinue_on]           DATETIME2 (7)   NULL,
    [created_at]               DATETIME2 (7)   NOT NULL,
    [quantity_limit_per_order] INT             NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

