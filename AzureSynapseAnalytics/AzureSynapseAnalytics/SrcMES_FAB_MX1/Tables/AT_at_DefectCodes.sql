CREATE TABLE [SrcMES_FAB_MX1].[AT_at_DefectCodes] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [atr_key]              BIGINT         NOT NULL,
    [atr_name]             NVARCHAR (64)  NOT NULL,
    [purge_status]         INT            NULL,
    [creation_time]        DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [xfr_insert_pid]       INT            NULL,
    [xfr_update_pid]       INT            NULL,
    [trx_id]               CHAR (38)      NOT NULL,
    [parent_key]           BIGINT         NULL,
    [pd_xfr_update_pid]    INT            NULL,
    [src_xfr_update_pid]   INT            NULL,
    [defectCode_I]         BIGINT         NULL,
    [defectDescription_S]  NVARCHAR (250) NULL,
    [defectName_S]         NVARCHAR (80)  NULL,
    [purged]               INT            NULL,
    [defectCategory_S]     NVARCHAR (16)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

