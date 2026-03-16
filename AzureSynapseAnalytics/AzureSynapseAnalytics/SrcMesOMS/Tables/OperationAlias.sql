CREATE TABLE [SrcMesOMS].[OperationAlias] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [operationAliasID]     INT           NOT NULL,
    [operationAliasName]   VARCHAR (50)  NOT NULL,
    [operationAliasPrefix] VARCHAR (3)   NULL,
    [isProduction]         BIT           NOT NULL,
    [isTraining]           BIT           NOT NULL,
    [isActive]             BIT           NOT NULL,
    [standardByScanType]   BIT           NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

