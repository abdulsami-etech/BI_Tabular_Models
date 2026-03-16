CREATE TABLE [SrcMAT].[BusinessPartner_BusinessPartnerTypeLink] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [BPBPTypeLinkID]        INT           NOT NULL,
    [BusinessPartnerID]     INT           NOT NULL,
    [BusinessPartnerTypeID] INT           NOT NULL,
    [RowStatusID]           INT           NOT NULL,
    [CreatedByUserID]       INT           NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [UpdatedByUserID]       INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

