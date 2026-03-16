CREATE TABLE [SrcMAT].[Address] (
    [LZBatchID]          INT            NOT NULL,
    [ADLSBatchID]        INT            NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)  NOT NULL,
    [AddressID]          INT            NOT NULL,
    [NumberOfReferences] INT            NOT NULL,
    [CountryID]          SMALLINT       NOT NULL,
    [CountryStateID]     INT            NOT NULL,
    [CountyID]           INT            NOT NULL,
    [CountyName]         NVARCHAR (100) NOT NULL,
    [TownID]             INT            NOT NULL,
    [TownName]           NVARCHAR (100) NOT NULL,
    [PostalCode]         NVARCHAR (10)  NOT NULL,
    [DoNotMail]          BIT            NOT NULL,
    [RowStatusID]        TINYINT        NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [CreatedByUserID]    INT            NOT NULL,
    [DateUpdated]        DATETIME       NULL,
    [UpdatedByUserID]    INT            NOT NULL,
    [IsValidAddress]     BIT            NULL,
    [AddressLine1]       NVARCHAR (35)  NOT NULL,
    [AddressLine2]       NVARCHAR (35)  NOT NULL,
    [AddressLine3]       NVARCHAR (35)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

