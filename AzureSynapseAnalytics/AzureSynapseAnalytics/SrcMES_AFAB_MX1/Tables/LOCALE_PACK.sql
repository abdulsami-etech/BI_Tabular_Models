CREATE TABLE [SrcMES_AFAB_MX1].[LOCALE_PACK] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [locale_pack_key]    BIGINT        NOT NULL,
    [site_num]           INT           NOT NULL,
    [message_pack_key]   BIGINT        NOT NULL,
    [font_name]          NVARCHAR (64) NULL,
    [font_size]          INT           NOT NULL,
    [xfr_insert_pid]     INT           NOT NULL,
    [xfr_update_pid]     INT           NOT NULL,
    [trx_id]             CHAR (38)     NOT NULL,
    [system_defined]     INT           NOT NULL,
    [locale_key]         BIGINT        NOT NULL,
    [pd_xfr_update_pid]  INT           NOT NULL,
    [src_xfr_update_pid] INT           NOT NULL,
    [purged]             INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

