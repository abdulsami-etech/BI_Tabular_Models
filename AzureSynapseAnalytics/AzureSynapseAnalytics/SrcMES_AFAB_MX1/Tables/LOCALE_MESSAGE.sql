CREATE TABLE [SrcMES_AFAB_MX1].[LOCALE_MESSAGE] (
    [LZBatchID]        INT             NOT NULL,
    [ADLSBatchID]      INT             NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)   NOT NULL,
    [locale_pack_key]  BIGINT          NOT NULL,
    [site_num]         INT             NOT NULL,
    [message_id]       NVARCHAR (64)   NOT NULL,
    [message]          NVARCHAR (1024) NOT NULL,
    [message_pack_key] BIGINT          NOT NULL,
    [xfr_insert_pid]   INT             NOT NULL,
    [xfr_update_pid]   INT             NOT NULL,
    [trx_id]           CHAR (38)       NOT NULL,
    [purged]           INT             NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

