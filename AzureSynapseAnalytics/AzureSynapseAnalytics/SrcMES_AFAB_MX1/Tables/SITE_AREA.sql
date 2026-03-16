CREATE TABLE [SrcMES_AFAB_MX1].[SITE_AREA] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [parent_key]         BIGINT        NOT NULL,
    [child_key]          BIGINT        NOT NULL,
    [site_num]           INT           NOT NULL,
    [xfr_insert_pid]     INT           NOT NULL,
    [pd_xfr_update_pid]  INT           NOT NULL,
    [src_xfr_update_pid] INT           NOT NULL,
    [xfr_update_pid]     INT           NOT NULL,
    [trx_id]             CHAR (38)     NOT NULL,
    [purged]             INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

