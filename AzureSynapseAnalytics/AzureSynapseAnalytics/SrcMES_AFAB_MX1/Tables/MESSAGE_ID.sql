CREATE TABLE [SrcMES_AFAB_MX1].[MESSAGE_ID] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [message_pack_key]   BIGINT        NOT NULL,
    [site_num]           INT           NOT NULL,
    [message_id]         NVARCHAR (64) NOT NULL,
    [xfr_insert_pid]     INT           NULL,
    [xfr_update_pid]     INT           NULL,
    [trx_id]             CHAR (38)     NULL,
    [pd_xfr_update_pid]  INT           NOT NULL,
    [src_xfr_update_pid] INT           NOT NULL,
    [purged]             INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

