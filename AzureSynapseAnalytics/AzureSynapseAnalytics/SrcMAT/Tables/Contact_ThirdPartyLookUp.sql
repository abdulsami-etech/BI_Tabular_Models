CREATE TABLE [SrcMAT].[Contact_ThirdPartyLookUp] (
    [LZBatchID]                  INT            NOT NULL,
    [ADLSBatchID]                INT            NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0)  NOT NULL,
    [Contact_ThirdPartyLookUpID] INT            NOT NULL,
    [ContactID]                  INT            NOT NULL,
    [BusinessPartnerID]          INT            NOT NULL,
    [ExternalIdentifier]         NVARCHAR (200) NULL,
    [RowStatusID]                TINYINT        NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [CreatedByUserID]            INT            NOT NULL,
    [DateUpdated]                DATETIME       NOT NULL,
    [UpdatedByUserID]            INT            NOT NULL,
    [LineOfBusiness]             NVARCHAR (100) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

