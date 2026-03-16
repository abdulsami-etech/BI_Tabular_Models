CREATE TABLE [SrcLoyalty].[LoyaltySummary] (
    [LZBatchID]         INT             NOT NULL,
    [ADLSBatchID]       INT             NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)   NOT NULL,
    [ClinId]            NVARCHAR (50)   NOT NULL,
    [LoyaltyPoints]     NUMERIC (18, 2) NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [EffectiveDateFrom] DATETIME        NOT NULL,
    [EffectiveDateTo]   DATETIME        NOT NULL,
    [DateUpdated]       DATETIME        NOT NULL
)
WITH (CLUSTERED INDEX([ClinId]), DISTRIBUTION = HASH([ClinId]));

