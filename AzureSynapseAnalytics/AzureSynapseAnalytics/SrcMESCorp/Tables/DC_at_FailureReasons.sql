CREATE TABLE [SrcMESCorp].[DC_at_FailureReasons] (
    [LZBatchID]            INT             NOT NULL,
    [ADLSBatchID]          INT             NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)   NOT NULL,
    [dc_instance_key]      BIGINT          NOT NULL,
    [site_num]             INT             NOT NULL,
    [creation_time]        DATETIME        NULL,
    [last_modified_time]   DATETIME        NULL,
    [object_key]           BIGINT          NOT NULL,
    [object_name]          NVARCHAR (128)  NULL,
    [object_type]          NVARCHAR (64)   NULL,
    [Comment]              NVARCHAR (2000) NULL,
    [FailureGroup]         NVARCHAR (80)   NULL,
    [FailureReason]        NVARCHAR (80)   NULL,
    [Fixed]                BIGINT          NULL,
    [Operation]            NVARCHAR (80)   NULL,
    [Team]                 NVARCHAR (80)   NULL,
    [Technician]           NVARCHAR (80)   NULL,
    [creation_time_u]      DATETIME        NULL,
    [creation_time_z]      NVARCHAR (64)   NULL,
    [last_modified_time_u] DATETIME        NULL,
    [last_modified_time_z] NVARCHAR (64)   NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

