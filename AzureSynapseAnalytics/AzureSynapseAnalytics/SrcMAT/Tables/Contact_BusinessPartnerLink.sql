CREATE TABLE [SrcMAT].[Contact_BusinessPartnerLink] (
    [LZBatchID]                    INT           NOT NULL,
    [ADLSBatchID]                  INT           NOT NULL,
    [ADLSTimestamp]                DATETIME2 (0) NOT NULL,
    [ContactBusinessPartnerLinkID] INT           NOT NULL,
    [ContactID]                    INT           NULL,
    [BusinessPartnerID]            INT           NULL,
    [FullOrdersVisibility]         INT           NULL,
    [IsAccountAdmin]               INT           NULL,
    [RowStatusID]                  INT           NULL,
    [DateCreated]                  DATETIME      NULL,
    [DateUpdated]                  DATETIME      NULL
)
WITH (CLUSTERED INDEX([ContactBusinessPartnerLinkID]), DISTRIBUTION = HASH([BusinessPartnerID]));

