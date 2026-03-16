CREATE TABLE [CTRL].[ETLBatchLog] (
    [SourceSystem] VARCHAR (32)    NOT NULL,
    [BatchID]      INT             NOT NULL,
    [StartTime]    DATETIME2 (3)   NOT NULL,
    [EndTime]      DATETIME2 (3)   NULL,
    [LoadStatus]   VARCHAR (50)    NOT NULL,
    [ErrorMessage] NVARCHAR (4000) NULL,
    CONSTRAINT [PK_ETLBatchLog] PRIMARY KEY CLUSTERED ([SourceSystem] ASC, [BatchID] ASC)
);

