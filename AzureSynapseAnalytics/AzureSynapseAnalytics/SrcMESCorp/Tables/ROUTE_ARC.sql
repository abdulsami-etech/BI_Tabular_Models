CREATE TABLE [SrcMESCorp].[ROUTE_ARC] (
    [LZBatchID]            INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [arc_key]              BIGINT         NOT NULL,
    [site_num]             INT            NOT NULL,
    [route_key]            BIGINT         NOT NULL,
    [from_node_key]        BIGINT         NOT NULL,
    [from_node_type]       NVARCHAR (50)  NOT NULL,
    [to_node_key]          BIGINT         NOT NULL,
    [to_node_type]         NVARCHAR (50)  NOT NULL,
    [arc_name]             NVARCHAR (64)  NOT NULL,
    [main_path]            INT            NOT NULL,
    [reason]               NVARCHAR (64)  NULL,
    [entry_rule]           NVARCHAR (255) NULL,
    [uda_0]                NVARCHAR (255) NULL,
    [uda_1]                NVARCHAR (255) NULL,
    [uda_2]                NVARCHAR (255) NULL,
    [uda_3]                NVARCHAR (255) NULL,
    [uda_4]                NVARCHAR (255) NULL,
    [last_modified_time]   DATETIME       NOT NULL,
    [last_modified_time_u] DATETIME       NULL,
    [last_modified_time_z] NVARCHAR (64)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

