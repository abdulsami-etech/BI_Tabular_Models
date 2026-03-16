CREATE TABLE [SrcMES_AFAB_MX1].[SHIFT] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [shift_key]            BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [shift_name]           NVARCHAR (64)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [creator_key]          BIGINT         NOT NULL,
    [creation_time]        DATETIME       NOT NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modifier_key]    BIGINT         NOT NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [xfr_insert_pid]       INT            NOT NULL,
    [xfr_update_pid]       INT            NOT NULL,
    [pd_xfr_update_pid]    INT            NOT NULL,
    [src_xfr_update_pid]   INT            NOT NULL,
    [trx_id]               CHAR (38)      NOT NULL,
    [update_privilege_key] BIGINT         NULL,
    [delete_privilege_key] BIGINT         NULL,
    [purged]               INT            NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

