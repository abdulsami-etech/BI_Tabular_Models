CREATE TABLE [SrcMESCorp].[TOBJ_QUEUE_HISTORY] (
    [LZBatchID]              INT            NOT NULL,
    [ADLSBatchID]            INT            NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)  NOT NULL,
    [tobj_queue_history_key] BIGINT         NOT NULL,
    [site_num]               INT            NOT NULL,
    [tobj_key]               BIGINT         NOT NULL,
    [tobj_type]              NVARCHAR (50)  NOT NULL,
    [route_key]              BIGINT         NULL,
    [route_name]             NVARCHAR (64)  NULL,
    [queue_key]              BIGINT         NULL,
    [queue_name]             NVARCHAR (64)  NULL,
    [begin_user_name]        NVARCHAR (64)  NULL,
    [begin_time]             DATETIME       NULL,
    [begin_comment]          NVARCHAR (255) NULL,
    [end_user_name]          NVARCHAR (64)  NULL,
    [end_time]               DATETIME       NULL,
    [end_comment]            NVARCHAR (255) NULL,
    [begin_time_u]           DATETIME       NULL,
    [begin_time_z]           NVARCHAR (64)  NULL,
    [end_time_u]             DATETIME       NULL,
    [end_time_z]             NVARCHAR (64)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([tobj_key]));

