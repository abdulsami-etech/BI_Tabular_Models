CREATE TABLE [SrcMESCorp].[AT_at_TechProfile] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [atr_key]              BIGINT        NOT NULL,
    [site_num]             INT           NOT NULL,
    [atr_name]             NVARCHAR (64) NULL,
    [creation_time]        DATETIME      NULL,
    [ProfileName_S]        NVARCHAR (80) NULL,
    [Status_Y]             TINYINT       NULL,
    [TechID_I]             BIGINT        NULL,
    [last_modified_time]   DATETIME      NULL,
    [creation_time_u]      DATETIME      NULL,
    [creation_time_z]      NVARCHAR (64) NULL,
    [last_modified_time_u] DATETIME      NULL,
    [last_modified_time_z] NVARCHAR (64) NULL,
    [parent_key]           BIGINT        NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

