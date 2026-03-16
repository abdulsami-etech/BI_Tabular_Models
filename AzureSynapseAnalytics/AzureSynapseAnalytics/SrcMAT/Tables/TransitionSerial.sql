CREATE TABLE [SrcMAT].[TransitionSerial] (
    [LZBatchID]           INT            NOT NULL,
    [ADLSBatchID]         INT            NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)  NOT NULL,
    [TransitionSerialID]  INT            NULL,
    [TransitionDetailsID] INT            NULL,
    [SerialCode]          NVARCHAR (100) NULL,
    [RowStatusID]         INT            NULL,
    [DateCreated]         DATETIME       NULL,
    [DateUpdated]         DATETIME       NULL
)
WITH (CLUSTERED INDEX([TransitionSerialID]), DISTRIBUTION = HASH([TransitionSerialID]));

