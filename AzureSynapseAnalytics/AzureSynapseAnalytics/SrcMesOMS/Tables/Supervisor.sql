CREATE TABLE [SrcMesOMS].[Supervisor] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [supervisorID]     INT           NOT NULL,
    [userID]           INT           NOT NULL,
    [isActive]         BIT           NOT NULL,
    [managerID]        INT           NULL,
    [creationDate]     DATETIME      NOT NULL,
    [modificationDate] DATETIME      NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

