CREATE TABLE [SrcInvisalignAccessories].[spree_products] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [id]                   INT            NOT NULL,
    [name]                 NVARCHAR (256) NOT NULL,
    [description]          NVARCHAR (MAX) NULL,
    [available_on]         DATETIME2 (7)  NULL,
    [deleted_at]           DATETIME2 (7)  NULL,
    [slug]                 NVARCHAR (256) NULL,
    [meta_description]     NVARCHAR (MAX) NULL,
    [meta_keywords]        NVARCHAR (256) NULL,
    [tax_category_id]      INT            NULL,
    [shipping_category_id] INT            NULL,
    [created_at]           DATETIME2 (7)  NOT NULL,
    [updated_at]           DATETIME2 (7)  NOT NULL,
    [promotionable]        BIT            NULL,
    [meta_title]           NVARCHAR (256) NULL,
    [discontinue_on]       DATETIME2 (7)  NULL,
    [instructions]         NVARCHAR (MAX) NULL,
    [content]              NVARCHAR (MAX) NULL,
    [storage]              NVARCHAR (MAX) NULL,
    [ingredients]          NVARCHAR (MAX) NULL,
    [disclaimer_text]      NVARCHAR (MAX) NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

