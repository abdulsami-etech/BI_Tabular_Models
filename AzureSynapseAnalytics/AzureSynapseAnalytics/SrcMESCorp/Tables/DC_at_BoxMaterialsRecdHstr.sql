CREATE TABLE [SrcMESCorp].[DC_at_BoxMaterialsRecdHstr] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [dc_instance_key]      BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [creation_time]        DATETIME       NULL,
    [last_modified_time]   DATETIME       NULL,
    [route_name]           NVARCHAR (64)  NULL,
    [op_name]              NVARCHAR (64)  NULL,
    [user_name]            NVARCHAR (64)  NULL,
    [object_key]           BIGINT         NOT NULL,
    [object_name]          NVARCHAR (128) NULL,
    [LowerTray]            BIGINT         NULL,
    [ModelInspection]      BIGINT         NULL,
    [PVSBite]              BIGINT         NULL,
    [ReasonCode]           NVARCHAR (80)  NULL,
    [UpperTray]            BIGINT         NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

