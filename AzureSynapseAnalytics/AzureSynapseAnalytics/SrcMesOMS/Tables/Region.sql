CREATE TABLE [SrcMesOMS].[Region] (
    [LZBatchID]           INT           NOT NULL,
    [ADLSBatchID]         INT           NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0) NOT NULL,
    [regionID]            INT           NOT NULL,
    [regionName]          VARCHAR (512) NOT NULL,
    [areaID]              INT           NOT NULL,
    [isActive]            BIT           NOT NULL,
    [isDeleted]           BIT           NOT NULL,
    [bonusBasedOnRejects] BIT           NOT NULL,
    [bonusBasedOnPPMs]    BIT           NOT NULL,
    [isForTraining]       BIT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

