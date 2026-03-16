CREATE TABLE [SrcMAT].[lcl_Country] (
    [LZBatchID]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [CountryID]     INT            NOT NULL,
    [CodeAlpha2]    NVARCHAR (10)  NULL,
    [CodeAlpha3]    NVARCHAR (10)  NULL,
    [CodeNumeric]   NVARCHAR (10)  NULL,
    [CountryName]   NVARCHAR (100) NULL,
    [DialingCode]   INT            NULL,
    [RowStatusID]   INT            NULL,
    [DateCreated]   DATETIME       NULL,
    [DateUpdated]   DATETIME       NULL
)
WITH (CLUSTERED INDEX([CountryID]), DISTRIBUTION = HASH([CountryID]));

