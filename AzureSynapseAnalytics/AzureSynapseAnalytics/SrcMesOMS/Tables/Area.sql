CREATE TABLE [SrcMesOMS].[Area] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [areaID]        INT           NOT NULL,
    [areaName]      VARCHAR (70)  NOT NULL,
    [areaPrefix]    VARCHAR (3)   NULL,
    [isActive]      BIT           NOT NULL,
    [isDeleted]     BIT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

