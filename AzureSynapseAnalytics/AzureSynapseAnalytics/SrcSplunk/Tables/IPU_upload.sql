CREATE TABLE [SrcSplunk].[IPU_upload] (
    [LZBatchID]           INT                NOT NULL,
    [ADLSBatchID]         INT                NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)      NOT NULL,
    [CATEGORY]            NVARCHAR (100)     NOT NULL,
    [SESSIONID]           NVARCHAR (50)      NOT NULL,
    [TS]                  DATETIMEOFFSET (7) NOT NULL,
    [_COUNT]              INT                NOT NULL,
    [APP_VERSION]         NVARCHAR (50)      NULL,
    [DATAUPLOAD_DURATION] NVARCHAR (50)      NULL,
    [DEVICE_ID]           NVARCHAR (50)      NULL,
    [DURATION]            NVARCHAR (50)      NULL,
    [_INDEX]              NVARCHAR (50)      NULL,
    [MODEL]               NVARCHAR (50)      NULL,
    [OS]                  NVARCHAR (50)      NULL,
    [OS_VERSION]          NVARCHAR (50)      NULL,
    [OUT_OF]              NVARCHAR (50)      NULL,
    [PHOTOSET_ID]         NVARCHAR (50)      NULL,
    [PHOTOSET_TYPE]       NVARCHAR (50)      NULL,
    [PHOTO_TYPE]          NVARCHAR (50)      NULL,
    [_USER]               NVARCHAR (50)      NULL,
    [iOS]                 NVARCHAR (50)      NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

