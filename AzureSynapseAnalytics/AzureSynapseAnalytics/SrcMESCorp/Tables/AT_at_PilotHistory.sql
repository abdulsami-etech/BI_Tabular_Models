CREATE TABLE [SrcMESCorp].[AT_at_PilotHistory] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [atr_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [atr_name]             NVARCHAR (64)  NOT NULL,
    [creation_time]        DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [comment_S]            NVARCHAR (360) NULL,
    [ids_id_S]             NVARCHAR (10)  NULL,
    [name_S]               NVARCHAR (100) NULL,
    [orderkey_S]           NVARCHAR (80)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

