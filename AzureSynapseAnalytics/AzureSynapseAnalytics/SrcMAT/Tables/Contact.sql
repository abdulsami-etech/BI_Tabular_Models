CREATE TABLE [SrcMAT].[Contact] (
    [LZBatchID]              INT            NOT NULL,
    [ADLSBatchID]            INT            NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)  NOT NULL,
    [ContactID]              INT            NOT NULL,
    [TitleTypeID]            SMALLINT       NOT NULL,
    [LastName]               NVARCHAR (100) NOT NULL,
    [FirstName]              NVARCHAR (100) NOT NULL,
    [MiddleName]             NVARCHAR (50)  NULL,
    [SuffixTypeID]           SMALLINT       NOT NULL,
    [DateOfBirth]            SMALLDATETIME  NULL,
    [Gender]                 CHAR (1)       NULL,
    [Notes]                  NVARCHAR (MAX) NOT NULL,
    [PersonalBadge]          VARCHAR (20)   NOT NULL,
    [LocaleID]               SMALLINT       NOT NULL,
    [PrimaryEmailLinkID]     INT            NULL,
    [PrimaryPhoneLinkID]     INT            NULL,
    [PrimaryAddressLinkID]   INT            NULL,
    [RowStatusID]            TINYINT        NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [CreatedByUserID]        INT            NOT NULL,
    [DateUpdated]            DATETIME       NOT NULL,
    [UpdatedByUserID]        INT            NOT NULL,
    [ContactFullName]        NVARCHAR (600) NULL,
    [ContactFullNameAddress] NVARCHAR (600) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

