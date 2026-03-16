CREATE TABLE [SrcMAT].[BusinessPartnerSalesforceLink] (
    [LZBatchID]                       INT            NOT NULL,
    [ADLSBatchID]                     INT            NOT NULL,
    [ADLSTimestamp]                   DATETIME2 (0)  NOT NULL,
    [BusinessPartnerSalesforceLinkId] INT            NOT NULL,
    [BusinessPartnerId]               INT            NULL,
    [SalesforceAccountNum]            NVARCHAR (100) NULL,
    [RowStatusID]                     TINYINT        NOT NULL,
    [DateCreated]                     DATETIME       NOT NULL,
    [CreatedByUserID]                 INT            NOT NULL,
    [DateUpdated]                     DATETIME       NOT NULL,
    [UpdatedByUserID]                 INT            NOT NULL,
    [LineOfBusiness]                  NVARCHAR (100) NULL,
    [LineOfBusinessFlag]              INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

