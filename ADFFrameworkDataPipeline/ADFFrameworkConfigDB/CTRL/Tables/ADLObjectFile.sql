CREATE TABLE [CTRL].[ADLObjectFile] (
    [FileName]        VARCHAR (128) NOT NULL,
    [Destination]     VARCHAR (64)  NOT NULL,
    [FilePath]        VARCHAR (128) NOT NULL,
    [ObjectID]        INT           NOT NULL,
    [Status]          VARCHAR (32)  NOT NULL,
    [DateUpdated]     DATETIME2 (3) NOT NULL,
    [IsFullLoad]      BIT           NOT NULL,
    [FileSizeInBytes] BIGINT        NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    CONSTRAINT [PK_ADLObjectFile] PRIMARY KEY CLUSTERED ([FileName] ASC, [Destination] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_ADLObjectFile_Status_Destination]
    ON [CTRL].[ADLObjectFile]([Status] ASC, [Destination] ASC)
    INCLUDE([ADLSBatchID], [FilePath], [FileSizeInBytes], [IsFullLoad], [ObjectID]);

