CREATE TABLE [SrcMAT].[Contact_PhoneTypeLink] (
    [LZBatchID]              INT           NOT NULL,
    [ADLSBatchID]            INT           NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0) NOT NULL,
    [ContactPhoneTypeLinkID] INT           NOT NULL,
    [ContactID]              INT           NOT NULL,
    [PhoneTypeID]            INT           NOT NULL,
    [PhoneID]                INT           NOT NULL,
    [PhoneExtension]         VARCHAR (10)  NULL,
    [IsPrimary]              INT           NOT NULL,
    [RowStatusID]            TINYINT       NOT NULL,
    [DateCreated]            DATETIME      NULL,
    [CreatedByUserID]        INT           NOT NULL,
    [DateUpdated]            DATETIME      NULL,
    [UpdatedByUserID]        INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

