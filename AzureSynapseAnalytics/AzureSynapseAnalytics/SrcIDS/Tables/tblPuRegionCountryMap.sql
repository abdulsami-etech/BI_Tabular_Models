CREATE TABLE [SrcIDS].[tblPuRegionCountryMap] (
    [LZBatchID]      INT            NOT NULL,
    [ADLSBatchID]    INT            NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)  NOT NULL,
    [region_code]    NVARCHAR (30)  NOT NULL,
    [country_code]   NVARCHAR (5)   NOT NULL,
    [country_name]   NVARCHAR (255) NULL,
    [localized_name] NVARCHAR (25)  NULL,
    [_Region]        VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([country_code]), DISTRIBUTION = HASH([country_code]));

