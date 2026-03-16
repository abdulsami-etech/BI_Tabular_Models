CREATE TABLE [DW].[DimTerritorySCD] (
    [SKTerritory]                INT           NOT NULL,
    [KeyTerritory]               NCHAR (18)    NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [LZBatchID]                  INT           NOT NULL,
    [DWBatchID]                  INT           NOT NULL,
    [DWHash]                     CHAR (40)     NOT NULL,
    [StartDateSCD]               DATE          NOT NULL,
    [EndDateSCD]                 DATE          NOT NULL,
    [TerritoryName]              NVARCHAR (25) NOT NULL,
    [TerritoryLabel]             NVARCHAR (80) NOT NULL,
    [TerritoryType]              NVARCHAR (80) NOT NULL,
    [SKUserOwner]                INT           NOT NULL,
    [SKTerritoryParentTerritory] INT           NULL,
    CONSTRAINT [PK_DimTerritorySCD] PRIMARY KEY NONCLUSTERED ([SKTerritory] ASC, [StartDateSCD] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKTerritory]), DISTRIBUTION = REPLICATE);

