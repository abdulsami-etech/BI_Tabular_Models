CREATE TABLE [SrcMesOMS].[Cell] (
    [LZBatchID]     INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [cellID]        INT           NOT NULL,
    [cellName]      VARCHAR (512) NOT NULL,
    [regionID]      INT           NOT NULL,
    [isActive]      BIT           NOT NULL,
    [isDeleted]     BIT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

