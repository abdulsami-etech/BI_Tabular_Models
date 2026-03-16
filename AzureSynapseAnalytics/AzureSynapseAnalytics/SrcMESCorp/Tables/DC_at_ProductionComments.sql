CREATE TABLE [SrcMESCorp].[DC_at_ProductionComments] (
    [LZBatchID]            INT             NOT NULL,
    [ADLSBatchID]          INT             NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)   NOT NULL,
    [dc_instance_key]      BIGINT          NOT NULL,
    [site_num]             INT             NOT NULL,
    [creation_time]        DATETIME        NULL,
    [last_modified_time]   DATETIME        NULL,
    [op_name]              NVARCHAR (64)   NULL,
    [user_name]            NVARCHAR (64)   NULL,
    [dscomment]            NVARCHAR (255)  NULL,
    [dslocation]           NVARCHAR (64)   NULL,
    [object_key]           BIGINT          NOT NULL,
    [object_name]          NVARCHAR (128)  NULL,
    [object_type]          NVARCHAR (64)   NULL,
    [Comment]              NVARCHAR (4000) NULL,
    [creation_time_u]      DATETIME        NULL,
    [creation_time_z]      NVARCHAR (64)   NULL,
    [last_modified_time_u] DATETIME        NULL,
    [last_modified_time_z] NVARCHAR (64)   NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([object_key]));

