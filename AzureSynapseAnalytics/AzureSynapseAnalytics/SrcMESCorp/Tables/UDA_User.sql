CREATE TABLE [SrcMESCorp].[UDA_User] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [object_key]           BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL,
    [at_Plant_S]           NVARCHAR (225) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

