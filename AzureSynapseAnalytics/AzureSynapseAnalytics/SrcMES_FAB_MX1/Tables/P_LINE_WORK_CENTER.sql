CREATE TABLE [SrcMES_FAB_MX1].[P_LINE_WORK_CENTER] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [parent_key]         BIGINT        NOT NULL,
    [child_key]          BIGINT        NOT NULL,
    [xfr_insert_pid]     INT           NOT NULL,
    [pd_xfr_update_pid]  INT           NOT NULL,
    [src_xfr_update_pid] INT           NOT NULL,
    [xfr_update_pid]     INT           NOT NULL,
    [trx_id]             CHAR (38)     NOT NULL,
    [purged]             INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

