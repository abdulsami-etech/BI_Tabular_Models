CREATE TABLE [SrcSplunk].[CCCloud_MoveAttachment] (
    [LZBatchID]     INT                NOT NULL,
    [ADLSBatchID]   INT                NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)      NOT NULL,
    [trace]         NVARCHAR (100)     NOT NULL,
    [action]        NVARCHAR (250)     NOT NULL,
    [ts]            DATETIMEOFFSET (7) NOT NULL,
    [_count]        INT                NOT NULL,
    [splunk_time]   DATETIMEOFFSET (7) NULL,
    [appVersion]    NVARCHAR (50)      NULL,
    [attachmentId]  NVARCHAR (10)      NULL,
    [movementType]  NVARCHAR (20)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

