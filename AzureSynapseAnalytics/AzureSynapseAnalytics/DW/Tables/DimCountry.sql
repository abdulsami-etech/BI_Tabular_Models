CREATE TABLE [DW].[DimCountry] (
    [SKCountry]            INT            IDENTITY (1, 1) NOT NULL,
    [CountryCode]          VARCHAR (10)   NOT NULL,
    [CountryName]          VARCHAR (256)  NOT NULL,
    [CountryGroup]         VARCHAR (256)  NOT NULL,
    [Region]               VARCHAR (256)  NOT NULL,
    [RegionGroup]          VARCHAR (256)  NOT NULL,
    [GlobalRegion]         VARCHAR (256)  NOT NULL,
    [iTeroReportingRegion] NVARCHAR (256) NULL
)
WITH (CLUSTERED INDEX([SKCountry]), DISTRIBUTION = REPLICATE);

