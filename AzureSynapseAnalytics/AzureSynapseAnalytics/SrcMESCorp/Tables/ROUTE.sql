CREATE TABLE [SrcMESCorp].[ROUTE] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [route_key]            BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [route_name]           NVARCHAR (64)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [cache_id]             INT            NOT NULL,
    [state]                NVARCHAR (50)  NULL,
    [reasons]              NVARCHAR (255) NULL,
    [creation_time]        DATETIME       NOT NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [version]              INT            NOT NULL,
    [uda_0]                NVARCHAR (255) NULL,
    [uda_1]                NVARCHAR (255) NULL,
    [uda_2]                NVARCHAR (255) NULL,
    [uda_3]                NVARCHAR (255) NULL,
    [uda_4]                NVARCHAR (255) NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

