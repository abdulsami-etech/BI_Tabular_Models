CREATE TABLE [DWTOPS].[FactLotLeadTime] (
    [ADLSBatchID]         INT           NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0) NOT NULL,
    [LZBatchID]           INT           NOT NULL,
    [DWBatchID]           INT           NOT NULL,
    [DgnCompleteDateTime] DATETIME      NULL,
    [DgnLotKey]           BIGINT        NOT NULL,
    [SKCompleteDate]      BIGINT        NULL,
    [TranslationHours]    INT           NULL,
    [HoldTimeHours]       INT           NULL,
    [LeadTimeHour]        INT           NULL,
    [CCModCount]          INT           NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([DgnLotKey]));

