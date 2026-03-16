CREATE TABLE [SrcMESCorp].[AT_at_Regions] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [atr_key]              BIGINT        NOT NULL,
    [site_num]             INT           NOT NULL,
    [atr_name]             NVARCHAR (64) NULL,
    [purge_status]         INT           NULL,
    [creation_time]        DATETIME      NULL,
    [xfr_insert_pid]       INT           NULL,
    [xfr_update_pid]       INT           NULL,
    [trx_id]               CHAR (38)     NOT NULL,
    [JDETeamNumber_S]      NVARCHAR (80) NULL,
    [last_modified_time]   DATETIME      NULL,
    [creation_time_u]      DATETIME      NULL,
    [creation_time_z]      NVARCHAR (64) NULL,
    [last_modified_time_u] DATETIME      NULL,
    [last_modified_time_z] NVARCHAR (64) NULL,
    [parent_key]           BIGINT        NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

