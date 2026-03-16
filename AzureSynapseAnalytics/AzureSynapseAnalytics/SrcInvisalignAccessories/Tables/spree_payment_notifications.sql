CREATE TABLE [SrcInvisalignAccessories].[spree_payment_notifications] (
    [LZBatchID]      INT            NOT NULL,
    [ADLSBatchID]    INT            NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)  NOT NULL,
    [id]             INT            NOT NULL,
    [params]         NVARCHAR (MAX) NULL,
    [status]         NVARCHAR (256) NULL,
    [transaction_id] NVARCHAR (256) NULL,
    [order_id]       INT            NULL,
    [created_at]     DATETIME2 (7)  NULL,
    [updated_at]     DATETIME2 (7)  NULL,
    [payment_id]     INT            NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

