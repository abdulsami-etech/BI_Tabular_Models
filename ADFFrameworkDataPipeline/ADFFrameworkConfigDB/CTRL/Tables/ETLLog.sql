CREATE TABLE [CTRL].[ETLLog] (
    [LogID]               INT             IDENTITY (1, 1) NOT NULL,
    [ObjectID]            INT             NOT NULL,
    [BatchID]             INT             NOT NULL,
    [PipelineName]        VARCHAR (50)    NOT NULL,
    [PipelineTriggerType] VARCHAR (50)    NULL,
    [LogType]             VARCHAR (50)    NULL,
    [SinkPathRAW]         VARCHAR (256)   NULL,
    [SinkName]            VARCHAR (256)   NULL,
    [DataSliceStartValue] VARCHAR (32)    NULL,
    [DataSliceEndValue]   VARCHAR (32)    NULL,
    [RowsInserted]        INT             NULL,
    [RowsUpdated]         INT             NULL,
    [StartTime]           DATETIME2 (3)   NOT NULL,
    [EndTime]             DATETIME2 (3)   NULL,
    [FileSizeInBytes]     BIGINT          NULL,
    [LoadStatus]          VARCHAR (50)    NOT NULL,
    [ErrorMessage]        NVARCHAR (4000) NULL,
    CONSTRAINT [PK_ETLLog] PRIMARY KEY CLUSTERED ([LogID] ASC)
);

