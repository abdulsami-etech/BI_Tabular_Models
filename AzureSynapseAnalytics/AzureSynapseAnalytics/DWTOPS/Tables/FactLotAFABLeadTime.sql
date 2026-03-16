CREATE TABLE [DWTOPS].[FactLotAFABLeadTime] (
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
CREATE NONCLUSTERED INDEX [IX_FactLotAFABLeadTime_SKCompleteDate]
    ON [DWTOPS].[FactLotAFABLeadTime]([SKCompleteDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactLotAFABLeadTime_SkCountry]
    ON [DWTOPS].[FactLotAFABLeadTime]([SkCountry] ASC);

