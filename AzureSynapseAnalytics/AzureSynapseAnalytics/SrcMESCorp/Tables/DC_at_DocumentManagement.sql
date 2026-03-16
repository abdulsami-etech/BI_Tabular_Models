CREATE TABLE [SrcMESCorp].[DC_at_DocumentManagement] (
    [LZBatchID]                INT            NOT NULL,
    [ADLSBatchID]              INT            NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)  NOT NULL,
    [dc_instance_key]          BIGINT         NOT NULL,
    [site_num]                 INT            NOT NULL,
    [creation_time]            DATETIME       NULL,
    [last_modified_time]       DATETIME       NULL,
    [object_key]               BIGINT         NOT NULL,
    [object_name]              NVARCHAR (128) NULL,
    [object_type]              NVARCHAR (64)  NULL,
    [FileName]                 NVARCHAR (250) NULL,
    [FileType]                 BIGINT         NULL,
    [FileVersion]              NVARCHAR (80)  NULL,
    [Operation]                NVARCHAR (80)  NULL,
    [ROID]                     BIGINT         NULL,
    [SendToCR]                 BIGINT         NULL,
    [StorageMethod]            NVARCHAR (80)  NULL,
    [ManufacturingOrderNumber] NVARCHAR (80)  NULL,
    [creation_time_u]          DATETIME       NULL,
    [creation_time_z]          NVARCHAR (64)  NULL,
    [last_modified_time_u]     DATETIME       NULL,
    [last_modified_time_z]     NVARCHAR (64)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([object_key]));

