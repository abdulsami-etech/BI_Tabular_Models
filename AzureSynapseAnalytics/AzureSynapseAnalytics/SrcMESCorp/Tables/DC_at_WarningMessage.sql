CREATE TABLE [SrcMESCorp].[DC_at_WarningMessage] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [dc_instance_key]      BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [creation_time]        DATETIME       NULL,
    [last_modified_time]   DATETIME       NULL,
    [user_name]            NVARCHAR (64)  NULL,
    [dscomment]            NVARCHAR (255) NULL,
    [object_name]          NVARCHAR (128) NULL,
    [object_type]          NVARCHAR (64)  NULL,
    [WarningDescription]   NVARCHAR (500) NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

