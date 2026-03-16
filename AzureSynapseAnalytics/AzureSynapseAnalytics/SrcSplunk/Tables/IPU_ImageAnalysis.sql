CREATE TABLE [SrcSplunk].[IPU_ImageAnalysis] (
    [LZBatchID]     INT                NOT NULL,
    [ADLSBatchID]   INT                NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)      NOT NULL,
    [CATEGORY]      NVARCHAR (100)     NOT NULL,
    [ACTION]        NVARCHAR (250)     NOT NULL,
    [SESSIONID]     NVARCHAR (50)      NOT NULL,
    [TS]            DATETIMEOFFSET (7) NOT NULL,
    [_COUNT]        INT                NOT NULL,
    [APP_VERSION]   NVARCHAR (50)      NULL,
    [DEVICE_ID]     NVARCHAR (50)      NULL,
    [DURATION]      NVARCHAR (50)      NULL,
    [LABEL]         NVARCHAR (50)      NULL,
    [MODEL]         NVARCHAR (50)      NULL,
    [OS]            NVARCHAR (50)      NULL,
    [OS_VERSION]    NVARCHAR (50)      NULL,
    [_USER]         NVARCHAR (50)      NULL,
    [_value]        NVARCHAR (50)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

