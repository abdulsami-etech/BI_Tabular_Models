CREATE TABLE [DW].[CaseStateHistory] (
    [DWBatchID]               INT            NOT NULL,
    [SAPOrdernumber]          NVARCHAR (64)  NOT NULL,
    [OrderStatus]             NVARCHAR (100) NULL,
    [StartTime_UTC]           DATETIME       NULL,
    [CompleteTime_UTC]        DATETIME       NULL,
    [OrderStatusDateTime_UTC] DATETIME       NULL,
    [HistoryKey]              BIGINT         NOT NULL,
    [SourceSystem]            VARCHAR (25)   NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrdernumber]));


GO
CREATE NONCLUSTERED INDEX [IX_CaseStateHistory_DWBatchID]
    ON [DW].[CaseStateHistory]([DWBatchID] ASC);

