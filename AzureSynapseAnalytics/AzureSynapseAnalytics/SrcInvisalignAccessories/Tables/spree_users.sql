CREATE TABLE [SrcInvisalignAccessories].[spree_users] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [id]                   INT           NOT NULL,
    [sign_in_count]        INT           NOT NULL,
    [failed_attempts]      INT           NOT NULL,
    [last_request_at]      DATETIME2 (7) NULL,
    [last_sign_in_at]      DATETIME2 (7) NULL,
    [ship_address_id]      INT           NULL,
    [bill_address_id]      INT           NULL,
    [locked_at]            DATETIME2 (7) NULL,
    [created_at]           DATETIME2 (7) NOT NULL,
    [updated_at]           DATETIME2 (7) NOT NULL,
    [spree_api_key]        NVARCHAR (48) NULL,
    [deleted_at]           DATETIME2 (7) NULL,
    [confirmed_at]         DATETIME2 (7) NULL,
    [confirmation_sent_at] DATETIME2 (7) NULL,
    [offers_enable]        BIT           NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

