CREATE TABLE [SrcMESCorp].[AT_at_CCModCategory] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [atr_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [atr_name]             NVARCHAR (64)  NOT NULL,
    [purge_status]         INT            NULL,
    [creation_time]        DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [description_S]        NVARCHAR (255) NULL,
    [id_I]                 BIGINT         NULL,
    [status_S]             NVARCHAR (20)  NULL,
    [user_name_S]          NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

