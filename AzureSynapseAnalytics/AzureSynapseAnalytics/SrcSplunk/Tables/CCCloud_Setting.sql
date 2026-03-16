CREATE TABLE [SrcSplunk].[CCCloud_Setting] (
    [LZBatchID]                 INT                NOT NULL,
    [ADLSBatchID]               INT                NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)      NOT NULL,
    [trace]                     NVARCHAR (100)     NOT NULL,
    [action]                    NVARCHAR (250)     NOT NULL,
    [ts]                        DATETIMEOFFSET (7) NOT NULL,
    [_count]                    INT                NOT NULL,
    [splunk_time]               DATETIMEOFFSET (7) NULL,
    [appVersion]                NVARCHAR (50)      NULL,
    [colorScheme]               NVARCHAR (50)      NULL,
    [includeBiteCorrection]     NVARCHAR (50)      NULL,
    [occlusionColors]           NVARCHAR (50)      NULL,
    [performance]               NVARCHAR (50)      NULL,
    [rotationMode]              NVARCHAR (50)      NULL,
    [transparencyTeeth]         NVARCHAR (50)      NULL,
    [attachmentColor_colorName] NVARCHAR (50)      NULL,
    [attachmentColor_value]     NVARCHAR (50)      NULL,
    [backgroundColor_colorName] NVARCHAR (50)      NULL,
    [backgroundColor_value]     NVARCHAR (50)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

