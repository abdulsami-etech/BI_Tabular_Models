CREATE TABLE [SrcMesOMS].[RttHead] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [rttHeadID]        INT           NOT NULL,
    [isActive]         BIT           NOT NULL,
    [userID]           INT           NOT NULL,
    [supervisorID]     INT           NOT NULL,
    [modifiedBy]       INT           NULL,
    [modificationDate] DATETIME      NULL,
    [isDeleted]        BIT           NOT NULL,
    [creationDate]     DATETIME      NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

