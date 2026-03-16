CREATE TABLE [SrcMES_FAB_MX1].[PROCESS_ORDER_ITEM] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [order_item_key]        BIGINT         NOT NULL,
    [order_key]             BIGINT         NOT NULL,
    [order_item_name]       NVARCHAR (64)  NOT NULL,
    [part_number]           NVARCHAR (64)  NOT NULL,
    [part_revision]         NVARCHAR (64)  NULL,
    [part_association_type] INT            NOT NULL,
    [quantity]              NVARCHAR (64)  NOT NULL,
    [category]              NVARCHAR (50)  NULL,
    [description]           NVARCHAR (255) NULL,
    [last_modified_time]    DATETIME       NOT NULL,
    [last_modified_time_u]  DATETIME       NULL,
    [last_modified_time_z]  NVARCHAR (64)  NULL,
    [xfr_insert_pid]        INT            NOT NULL,
    [pd_xfr_update_pid]     INT            NOT NULL,
    [src_xfr_update_pid]    INT            NOT NULL,
    [xfr_update_pid]        INT            NOT NULL,
    [trx_id]                CHAR (38)      NOT NULL,
    [purged]                INT            NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([order_key]));

