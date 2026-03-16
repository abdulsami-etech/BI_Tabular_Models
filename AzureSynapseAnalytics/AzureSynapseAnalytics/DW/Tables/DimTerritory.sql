CREATE TABLE [DW].[DimTerritory] (
    [SKTerritory]                INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [LZBatchID]                  INT           NOT NULL,
    [DWBatchID]                  INT           NOT NULL,
    [DWHash]                     CHAR (40)     NOT NULL,
    [KeyTerritory]               NCHAR (18)    NOT NULL,
    [TerritoryName]              NVARCHAR (25) NOT NULL,
    [TerritoryLabel]             NVARCHAR (80) NOT NULL,
    [TerritoryType]              NVARCHAR (80) NOT NULL,
    [SKUserOwner]                INT           NOT NULL,
    [SKTerritoryParentTerritory] INT           NULL,
    CONSTRAINT [PK_DimTerritory] PRIMARY KEY NONCLUSTERED ([SKTerritory] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimTerritory_KeyTerritory] UNIQUE NONCLUSTERED ([KeyTerritory] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimTerritory_TerritoryName] UNIQUE NONCLUSTERED ([TerritoryName] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKTerritory]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_DimTerritory_KeyTerritory]
    ON [DW].[DimTerritory]([KeyTerritory] ASC);

