CREATE TABLE [SrcMESCorp].[ROUTE_STEP] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [route_step_key]       BIGINT        NOT NULL,
    [site_num]             INT           NOT NULL,
    [route_key]            BIGINT        NOT NULL,
    [op_key]               BIGINT        NOT NULL,
    [route_step_name]      NVARCHAR (64) NOT NULL,
    [route_step_type]      NVARCHAR (50) NOT NULL,
    [last_modified_time]   DATETIME      NOT NULL,
    [last_modified_time_u] DATETIME      NULL,
    [last_modified_time_z] NVARCHAR (64) NULL,
    [category]             NVARCHAR (50) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

