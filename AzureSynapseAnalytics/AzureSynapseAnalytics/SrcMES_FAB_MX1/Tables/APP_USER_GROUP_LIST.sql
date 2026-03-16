CREATE TABLE [SrcMES_FAB_MX1].[APP_USER_GROUP_LIST] (
    [LZBatchID]               INT           NOT NULL,
    [ADLSBatchID]             INT           NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0) NOT NULL,
    [app_user_group_list_key] BIGINT        NOT NULL,
    [user_key]                BIGINT        NOT NULL,
    [group_key]               BIGINT        NOT NULL,
    [role]                    NVARCHAR (64) NULL,
    [xfr_insert_pid]          INT           NOT NULL,
    [pd_xfr_update_pid]       INT           NOT NULL,
    [src_xfr_update_pid]      INT           NOT NULL,
    [xfr_update_pid]          INT           NOT NULL,
    [trx_id]                  CHAR (38)     NOT NULL,
    [purged]                  INT           NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

