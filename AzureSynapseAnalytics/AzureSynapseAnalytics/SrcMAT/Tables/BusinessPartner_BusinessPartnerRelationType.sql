CREATE TABLE [SrcMAT].[BusinessPartner_BusinessPartnerRelationType] (
    [LZBatchID]                                     INT           NOT NULL,
    [ADLSBatchID]                                   INT           NOT NULL,
    [ADLSTimestamp]                                 DATETIME2 (0) NOT NULL,
    [BusinessPartnerRelationTypeID]                 INT           NOT NULL,
    [BusinessPartnerRelationTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [RowStatusID]                                   INT           NOT NULL,
    [DateCreated]                                   DATETIME      NOT NULL,
    [CreatedByUserID]                               INT           NOT NULL,
    [DateUpdated]                                   DATETIME      NOT NULL,
    [UpdatedByUserID]                               INT           NOT NULL,
    [IsBillingRelated]                              INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

