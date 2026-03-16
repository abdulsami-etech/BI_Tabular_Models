CREATE TABLE [SrcMAT].[CountryState] (
    [LZBatchID]              INT            NOT NULL,
    [ADLSBatchID]            INT            NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)  NOT NULL,
    [CountryStateID]         INT            NOT NULL,
    [CountryID]              SMALLINT       NOT NULL,
    [StateCode]              CHAR (10)      NOT NULL,
    [StateNameEN]            VARCHAR (50)   NOT NULL,
    [StateNameLocalLanguage] NVARCHAR (100) NOT NULL,
    [RowStatusID]            TINYINT        NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [CreatedByUserID]        INT            NOT NULL,
    [DateUpdated]            DATETIME       NOT NULL,
    [UpdatedByUserID]        INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

