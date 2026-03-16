CREATE TABLE [SrcMES_AFAB_MX1].[LOT_FLOW_TRACKING] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [lot_key]               BIGINT          NOT NULL,
    [tobj_status_key]       BIGINT          NOT NULL,
    [site_num]              INT             NOT NULL,
    [lot_type]              INT             NULL,
    [quantity]              NUMERIC (23, 9) NULL,
    [xfr_insert_pid]        INT             NULL,
    [xfr_update_pid]        INT             NULL,
    [trx_id]                CHAR (38)       NOT NULL,
    [last_modified_time]    DATETIME        NOT NULL,
    [container_key]         BIGINT          NULL,
    [container_name]        NVARCHAR (128)  NULL,
    [container_type]        NVARCHAR (50)   NULL,
    [container_sub_type]    INT             NULL,
    [lot_flow_tracking_key] BIGINT          NOT NULL,
    [last_modified_time_u]  DATETIME        NULL,
    [last_modified_time_z]  NVARCHAR (64)   NULL,
    [pd_xfr_update_pid]     INT             NOT NULL,
    [src_xfr_update_pid]    INT             NOT NULL,
    [purged]                INT             NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([lot_key]));

