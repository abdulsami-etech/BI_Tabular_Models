CREATE TABLE [Custom].[GeographyHierarchy] (
    [SKGeography]  INT           IDENTITY (1, 1) NOT NULL,
    [CountryCode]  NVARCHAR (3)  NOT NULL,
    [Country]      NVARCHAR (50) NOT NULL,
    [CountryGroup] NVARCHAR (50) NOT NULL,
    [RegionPC]     NVARCHAR (50) NOT NULL,
    [RegionGroup]  NVARCHAR (50) NOT NULL,
    [GlobalRegion] NVARCHAR (32) NOT NULL,
    [SecRegion]    VARCHAR (10)  NULL,
    [CountryGoogleName] NVARCHAR (50) NULL
)
WITH (CLUSTERED INDEX([SKGeography]), DISTRIBUTION = REPLICATE);

