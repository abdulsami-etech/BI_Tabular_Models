CREATE TABLE [SrcMES_AFAB_MX2].[MESSAGE_PACK] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [message_pack_key]     BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [message_pack_name]    NVARCHAR (64)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [creator_key]          BIGINT         NULL,
    [creation_time]        DATETIME       NULL,
    [last_modifier_key]    BIGINT         NULL,
    [last_modified_time]   DATETIME       NULL,
    [xfr_insert_pid]       INT            NULL,
    [xfr_update_pid]       INT            NULL,
    [trx_id]               CHAR (38)      NULL,
    [system_defined]       INT            NOT NULL,
    [update_privilege_key] BIGINT         NULL,
    [delete_privilege_key] BIGINT         NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [pd_xfr_update_pid]    INT            NOT NULL,
    [src_xfr_update_pid]   INT            NOT NULL,
    [purged]               INT            NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

