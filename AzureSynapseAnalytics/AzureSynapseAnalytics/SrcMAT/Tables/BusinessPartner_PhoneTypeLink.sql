CREATE TABLE [SrcMAT].[BusinessPartner_PhoneTypeLink] (
    [LZBatchID]                      INT           NOT NULL,
    [ADLSBatchID]                    INT           NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0) NOT NULL,
    [BusinessPartnerPhoneTypeLinkID] INT           NOT NULL,
    [BusinessPartnerID]              INT           NOT NULL,
    [PhoneTypeID]                    SMALLINT      NOT NULL,
    [PhoneID]                        INT           NOT NULL,
    [PhoneExtension]                 VARCHAR (50)  NULL,
    [IsPrimary]                      BIT           NOT NULL,
    [RowStatusID]                    TINYINT       NOT NULL,
    [DateCreated]                    DATETIME      NULL,
    [CreatedByUserID]                INT           NOT NULL,
    [DateUpdated]                    DATETIME      NULL,
    [UpdatedByUserID]                INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

