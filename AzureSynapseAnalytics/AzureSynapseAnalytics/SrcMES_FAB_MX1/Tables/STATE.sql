CREATE TABLE [SrcMES_FAB_MX1].[STATE] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [state_key]             BIGINT        NOT NULL,
    [state_name]            NVARCHAR (64) NULL,
    [state_name_message_id] NVARCHAR (64) NULL,
    [fsm_key]               BIGINT        NOT NULL,
    [sem_prop_list_key]     BIGINT        NOT NULL,
    [last_modified_time]    DATETIME      NOT NULL,
    [last_modified_time_u]  DATETIME      NULL,
    [last_modified_time_z]  NVARCHAR (64) NULL,
    [xfr_insert_pid]        INT           NOT NULL,
    [pd_xfr_update_pid]     INT           NOT NULL,
    [src_xfr_update_pid]    INT           NOT NULL,
    [xfr_update_pid]        INT           NOT NULL,
    [trx_id]                CHAR (38)     NOT NULL,
    [purged]                INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

