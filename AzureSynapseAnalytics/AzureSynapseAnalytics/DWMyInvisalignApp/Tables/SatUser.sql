CREATE TABLE [DWMyInvisalignApp].[SatUser] (
    [SKUser]        INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [LZBatchID]     INT            NOT NULL,
    [DWBatchID]     INT            NOT NULL,
    [DWHash]        CHAR (40)      NOT NULL,
    [Continent]     NVARCHAR (100) NULL,
    [SubContinent]  NVARCHAR (100) NULL,
    [Region]        NVARCHAR (100) NULL,
    [Country]       NVARCHAR (100) NULL,
    [City]          NVARCHAR (100) NULL,
    [Metro]         NVARCHAR (100) NULL
)
WITH (CLUSTERED INDEX([SKUser]), DISTRIBUTION = REPLICATE);

