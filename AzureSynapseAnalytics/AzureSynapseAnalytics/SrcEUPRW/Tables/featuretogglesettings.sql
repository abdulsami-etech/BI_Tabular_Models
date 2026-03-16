CREATE TABLE [SrcEUPRW].[featuretogglesettings] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [id]            VARCHAR (255) NOT NULL,
    [isactive]      BIT           NOT NULL,
    [description]   VARCHAR (255) NOT NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

