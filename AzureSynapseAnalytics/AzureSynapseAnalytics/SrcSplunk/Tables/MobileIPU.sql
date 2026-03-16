CREATE TABLE [SrcSplunk].[MobileIPU] (
    [LZBatchID]      INT             NOT NULL,
    [ADLSBatchID]    INT             NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)   NOT NULL,
    [LogTimestamp]   DATETIME2 (0)   NOT NULL,
    [DEVICE_ID]      VARCHAR (36)    NOT NULL,
    [CATEGORY]       VARCHAR (64)    NOT NULL,
    [ACTION]         VARCHAR (128)   NOT NULL,
    [PHOTO_TYPE]     VARCHAR (64)    NOT NULL,
    [_count]         INT             NOT NULL,
    [APP_VERSION]    VARCHAR (32)    NULL,
    [MODEL]          VARCHAR (64)    NULL,
    [OS]             VARCHAR (32)    NULL,
    [OS_VERSION]     VARCHAR (32)    NULL,
    [SESSION_ID]     VARCHAR (36)    NULL,
    [USER]           VARCHAR (64)    NULL,
    [PHOTO_SET_ID]   VARCHAR (64)    NULL,
    [PHOTO_SET_TYPE] VARCHAR (64)    NULL,
    [DURATION]       NUMERIC (18, 3) NULL,
    [LOG_TYPE]       VARCHAR (64)    NULL,
    [MESSAGE]        VARCHAR (4000)  NULL,
    [STATUS_CODE]    INT             NULL,
    [URL]            VARCHAR (4000)  NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

