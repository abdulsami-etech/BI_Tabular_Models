CREATE TABLE [DWTOPS].[DimOperation] (
    [SKOperation]          INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [LZBatchID]            INT           NOT NULL,
    [DWBatchID]            INT           NOT NULL,
    [DWHash]               CHAR (40)     NOT NULL,
    [KeyOperation]         BIGINT        NOT NULL,
    [OperationName]        VARCHAR (64)  NOT NULL,
    [OperationDescription] VARCHAR (255) NULL,
    [OperationCategory]    VARCHAR (50)  NOT NULL
)
WITH (CLUSTERED INDEX([SKOperation]), DISTRIBUTION = REPLICATE);

