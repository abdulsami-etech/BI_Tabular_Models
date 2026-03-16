CREATE TABLE [SrcMESCorp].[DCS_PARM] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [dcs_key]              BIGINT         NOT NULL,
    [parm]                 NVARCHAR (30)  NOT NULL,
    [site_num]             INT            NOT NULL,
    [type]                 NVARCHAR (50)  NOT NULL,
    [description]          NVARCHAR (255) NULL,
    [prompt]               NVARCHAR (255) NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

