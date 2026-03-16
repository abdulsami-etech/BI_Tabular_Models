CREATE TABLE [SrcMESCorp].[SITE] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [site_key]             BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [site_name]            NVARCHAR (64)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [creation_time]        DATETIME       NOT NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

