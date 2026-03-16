CREATE TABLE [DW].[DimAccountTerritoryAssociation] (
    [SKAccount]     INT           NOT NULL,
    [SKTerritory]   INT           NOT NULL,
    [ADLSBatchID]   INT           NOT NULL,
    [ADLSTimestamp] DATETIME2 (0) NOT NULL,
    [LZBatchID]     INT           NOT NULL,
    [DWBatchID]     INT           NOT NULL,
    [Id]            NCHAR (18)    NOT NULL,
    [KeyAccount]    NCHAR (18)    NOT NULL,
    [KeyTerritory]  NCHAR (18)    NOT NULL,
    CONSTRAINT [PK_DimAccountTerritoryAssociation] PRIMARY KEY NONCLUSTERED ([SKAccount] ASC, [SKTerritory] ASC) NOT ENFORCED
)
WITH (HEAP, DISTRIBUTION = REPLICATE);


GO
CREATE CLUSTERED INDEX [IX_CL_DimAccountTerritoryAssociation]
    ON [DW].[DimAccountTerritoryAssociation]([SKAccount] ASC);

