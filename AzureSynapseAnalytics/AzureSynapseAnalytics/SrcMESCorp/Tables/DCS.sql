CREATE TABLE [SrcMESCorp].[DCS] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [dcs_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [dcs_name]             NVARCHAR (26)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [category]             NVARCHAR (50)  NULL,
    [creation_time]        DATETIME       NOT NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [checkout_user_key]    BIGINT         NULL,
    [rt_dcs_name]          NVARCHAR (30)  NOT NULL,
    [creation_time_u]      DATETIME       NULL,
    [creation_time_z]      NVARCHAR (64)  NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

