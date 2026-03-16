CREATE TABLE [SrcSplunk].[CCCloud_3DMod] (
    [LZBatchID]     INT                NOT NULL,
    [ADLSBatchID]   INT                NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)      NOT NULL,
    [trace]         NVARCHAR (100)     NOT NULL,
    [action]        NVARCHAR (250)     NOT NULL,
    [ts]            DATETIMEOFFSET (7) NOT NULL,
    [tooth]         NVARCHAR (10)      NOT NULL,
    [_count]        INT                NOT NULL,
    [splunk_time]   DATETIMEOFFSET (7) NULL,
    [appVersion]    NVARCHAR (50)      NULL,
    [_all]          NVARCHAR (10)      NULL,
    [attachments]   NVARCHAR (10)      NULL,
    [cuts]          NVARCHAR (10)      NULL,
    [fipos]         NVARCHAR (10)      NULL,
    [kind]          NVARCHAR (50)      NULL,
    [newSize]       NVARCHAR (10)      NULL,
    [occplanangle]  NVARCHAR (10)      NULL,
    [placingType]   NVARCHAR (50)      NULL,
    [surface]       NVARCHAR (10)      NULL,
    [toothId]       NVARCHAR (10)      NULL,
    [_type]         NVARCHAR (50)      NULL,
    [_value]        NVARCHAR (50)      NULL,
    [way]           NVARCHAR (10)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

