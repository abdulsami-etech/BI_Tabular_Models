CREATE TABLE [SrcMAT].[BusinessPartner_eMailTypeLink] (
    [LZBatchID]                      INT            NOT NULL,
    [ADLSBatchID]                    INT            NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0)  NOT NULL,
    [BusinessPartnerEmailTypeLinkID] INT            NOT NULL,
    [BusinessPartnerID]              INT            NOT NULL,
    [eMailTypeID]                    SMALLINT       NOT NULL,
    [eMailID]                        INT            NOT NULL,
    [DisplayName]                    NVARCHAR (250) NOT NULL,
    [RowStatusID]                    TINYINT        NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [CreatedByUserID]                INT            NOT NULL,
    [DateUpdated]                    DATETIME       NULL,
    [UpdatedByUserID]                INT            NOT NULL,
    [IsPrimary]                      BIT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

