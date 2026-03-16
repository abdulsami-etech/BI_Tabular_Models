CREATE TABLE [SrcMESCorp].[LOT_FLOW_TRACKING] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [lot_key]               BIGINT          NOT NULL,
    [tobj_status_key]       BIGINT          NOT NULL,
    [site_num]              INT             NOT NULL,
    [lot_type]              INT             NULL,
    [quantity]              NUMERIC (23, 9) NULL,
    [last_modified_time]    DATETIME        NOT NULL,
    [lot_flow_tracking_key] BIGINT          NOT NULL,
    [last_modified_time_u]  DATETIME        NULL,
    [last_modified_time_z]  NVARCHAR (64)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([lot_key]));

