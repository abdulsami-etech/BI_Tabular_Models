CREATE TABLE [SrcMAT].[BusinessPartner_BusinessPartnerRelationLink] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [RelationID]                    INT           NOT NULL,
    [BusinessPartnerRelationTypeID] INT           NOT NULL,
    [FirstBusinessPartnerID]        INT           NOT NULL,
    [SecondBusinessPartnerID]       INT           NOT NULL,
    [RowStatusID]                   INT           NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [CreatedByUserID]               INT           NOT NULL,
    [DateUpdated]                   DATETIME      NOT NULL,
    [UpdatedByUserID]               INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

