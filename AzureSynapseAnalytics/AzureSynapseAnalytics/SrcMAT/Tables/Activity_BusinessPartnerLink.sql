CREATE TABLE [SrcMAT].[Activity_BusinessPartnerLink] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [ActivityBusinessPartnerLinkID] INT           NOT NULL,
    [BusinessPartnerID]             INT           NOT NULL,
    [ActivityID]                    INT           NOT NULL,
    [RowStatusID]                   TINYINT       NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [CreatedByUserID]               INT           NOT NULL,
    [DateUpdated]                   DATETIME      NOT NULL,
    [UpdatedByUserID]               INT           NOT NULL
)
WITH (CLUSTERED INDEX([ActivityBusinessPartnerLinkID]), DISTRIBUTION = HASH([ActivityBusinessPartnerLinkID]));

