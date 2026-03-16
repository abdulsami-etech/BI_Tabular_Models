CREATE TABLE [SrcInvisalignAccessories].[spree_payments] (
    [LZBatchID]            INT             NOT NULL,
    [ADLSBatchID]          INT             NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)   NOT NULL,
    [id]                   INT             NOT NULL,
    [amount]               NUMERIC (10, 2) NOT NULL,
    [order_id]             INT             NULL,
    [source_type]          NVARCHAR (256)  NULL,
    [source_id]            INT             NULL,
    [payment_method_id]    INT             NULL,
    [state]                NVARCHAR (256)  NULL,
    [response_code]        NVARCHAR (256)  NULL,
    [avs_response]         NVARCHAR (256)  NULL,
    [created_at]           DATETIME2 (7)   NOT NULL,
    [updated_at]           DATETIME2 (7)   NOT NULL,
    [number]               NVARCHAR (256)  NULL,
    [cvv_response_code]    NVARCHAR (256)  NULL,
    [cvv_response_message] NVARCHAR (256)  NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = ROUND_ROBIN);

