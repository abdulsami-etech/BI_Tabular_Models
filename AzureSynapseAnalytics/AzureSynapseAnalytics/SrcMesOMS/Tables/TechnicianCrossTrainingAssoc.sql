CREATE TABLE [SrcMesOMS].[TechnicianCrossTrainingAssoc] (
    [LZBatchID]        INT             NOT NULL,
    [ADLSBatchID]      INT             NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)   NOT NULL,
    [technicianID]     INT             NOT NULL,
    [operationID]      INT             NOT NULL,
    [efficiency]       DECIMAL (18, 2) NOT NULL,
    [creationDate]     DATETIME        NOT NULL,
    [modificationDate] DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

