CREATE TABLE [DWTOPS].[FactLotAFABCNLeadTime] (
    [ADLSBatchID]         INT           NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0) NOT NULL,
    [LZBatchID]           INT           NOT NULL,
    [DWBatchID]           INT           NOT NULL,
    [DgnCompleteDateTime] DATETIME      NULL,
    [DgnLotKey]           BIGINT        NOT NULL,
    [SKPlant]             INT           NULL,
    [SKCompleteDate]      BIGINT        NULL,
    [SkCountry]           INT           NULL,
    [TreatmentOption]     NVARCHAR (80) NULL,
    [TreatmentCategory]   NVARCHAR (80) NULL,
    [LeadTimeHour]        INT           NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([DgnLotKey]));


GO
CREATE NONCLUSTERED INDEX [IX_FactLotAFABCNLeadTime_SKCompleteDate]
    ON [DWTOPS].[FactLotAFABCNLeadTime]([SKCompleteDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactLotAFABCNLeadTime_SkCountry]
    ON [DWTOPS].[FactLotAFABCNLeadTime]([SkCountry] ASC);