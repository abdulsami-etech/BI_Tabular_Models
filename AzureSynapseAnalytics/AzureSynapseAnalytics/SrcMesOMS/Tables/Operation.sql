CREATE TABLE [SrcMesOMS].[Operation] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [operationID]           INT             NOT NULL,
    [operationName]         VARCHAR (100)   NOT NULL,
    [standardTimeOperation] NUMERIC (18, 3) NOT NULL,
    [isActive]              BIT             NOT NULL,
    [operationAliasID]      INT             NOT NULL,
    [isTeamProductivity]    BIT             NOT NULL,
    [isDeleted]             BIT             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

