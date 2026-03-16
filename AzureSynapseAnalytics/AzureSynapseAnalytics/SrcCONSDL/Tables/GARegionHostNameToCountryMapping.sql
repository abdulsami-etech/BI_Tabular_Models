CREATE TABLE [SrcCONSDL].[GARegionHostNameToCountryMapping] (
    [LZBatchID]           INT            NOT NULL,
    [ADLSBatchID]         INT            NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)  NOT NULL,
    [GARegion]            NVARCHAR (100) NOT NULL,
    [HostName]            NVARCHAR (100) NOT NULL,
    [CountryFromHostName] NVARCHAR (200) NOT NULL,
    [IsValid]             BIT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = REPLICATE);

