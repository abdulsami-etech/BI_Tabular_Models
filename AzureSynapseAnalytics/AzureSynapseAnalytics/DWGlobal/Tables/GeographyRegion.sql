CREATE TABLE [DWGlobal].[GeographyRegion] (
    [SKGeography] INT          IDENTITY (1, 1) NOT NULL,
    [RegionGroup] VARCHAR (50) NOT NULL,
    [DataSet]     VARCHAR (30) NOT NULL
)
WITH (CLUSTERED INDEX([SKGeography]), DISTRIBUTION = REPLICATE);

