CREATE TABLE [SrcPWA].[program_enrollments] (
    [LZBatchID]         INT            NOT NULL,
    [ADLSBatchID]       INT            NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)  NOT NULL,
    [id]                INT            NULL,
    [program_id]        INT            NULL,
    [status]            INT            NULL,
    [pdf]               NVARCHAR (255) NULL,
    [created_at]        DATETIME       NULL,
    [updated_at]        DATETIME       NULL,
    [program_option_id] INT            NULL,
    [username]          NVARCHAR (255) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

