CREATE TABLE [DWTOPS].[DimPlant] (
    [SKPlant]          INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [LZBatchID]        INT           NOT NULL,
    [DWBatchID]        INT           NOT NULL,
    [DWHash]           CHAR (40)     NOT NULL,
    [KeyPlant]         VARCHAR (64)  NOT NULL,
    [PlantDescription] VARCHAR (255) NULL,
    [PlantCategory]    VARCHAR (50)  NULL
)
WITH (CLUSTERED INDEX([SKPlant]), DISTRIBUTION = REPLICATE);

