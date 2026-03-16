CREATE TABLE [SrcSplunk].[CCCloud_ToothMove] (
    [LZBatchID]     INT                NOT NULL,
    [ADLSBatchID]   INT                NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)      NOT NULL,
    [trace]         NVARCHAR (100)     NOT NULL,
    [action]        NVARCHAR (250)     NOT NULL,
    [ts]            DATETIMEOFFSET (7) NOT NULL,
    [_count]        INT                NOT NULL,
    [splunk_time]   DATETIMEOFFSET (7) NULL,
    [appVersion]    NVARCHAR (50)      NULL,
    [performedBy]   NVARCHAR (50)      NULL,
    [teeth]         NVARCHAR (250)     NULL,
    [type]          NVARCHAR (50)      NULL,
    [_value]        NVARCHAR (50)      NULL,
    [widgetType]    NVARCHAR (50)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

