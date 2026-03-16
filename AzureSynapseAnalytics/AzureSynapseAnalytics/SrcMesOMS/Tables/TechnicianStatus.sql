CREATE TABLE [SrcMesOMS].[TechnicianStatus] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [technicianStatusID] INT           NOT NULL,
    [statusName]         VARCHAR (100) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

