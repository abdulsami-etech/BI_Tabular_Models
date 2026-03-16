CREATE TABLE [SrcMAT].[BusinessPartner_AddressTypeLink] (
    [LZBatchID]                    INT           NOT NULL,
    [ADLSBatchID]                  INT           NOT NULL,
    [ADLSTimestamp]                DATETIME2 (0) NOT NULL,
    [BusinessPartnerID]            INT           NOT NULL,
    [AddressTypeID]                SMALLINT      NOT NULL,
    [BusinessPartnerAddressTypeID] INT           NOT NULL,
    [AddressID]                    INT           NOT NULL,
    [RowStatusID]                  TINYINT       NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [CreatedByUserID]              INT           NOT NULL,
    [DateUpdated]                  DATETIME      NULL,
    [UpdatedByUserID]              INT           NOT NULL,
    [IsPrimary]                    BIT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

