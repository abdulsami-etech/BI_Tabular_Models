CREATE TABLE [SrcMESCorp].[AT_at_Impression_Type_History] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [atr_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [atr_name]             NVARCHAR (64)  NOT NULL,
    [purge_status]         INT            NULL,
    [creation_time]        DATETIME       NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [parent_key]           BIGINT         NULL,
    [impression_type_S]    NVARCHAR (500) NULL,
    [object_key_I]         BIGINT         NULL,
    [order_number_I]       BIGINT         NULL,
    [username_S]           NVARCHAR (500) NULL,
    [hardware_version_S]   NVARCHAR (50)  NULL,
    [software_version_S]   NVARCHAR (50)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

