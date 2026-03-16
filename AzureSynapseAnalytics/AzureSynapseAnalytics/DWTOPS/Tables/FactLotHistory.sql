CREATE TABLE [DWTOPS].[FactLotHistory]
(
	[ADLSBatchId] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NULL,
	[DgnCompleteDateTime] [datetime] NULL,
	[DgnStartDateTime] [datetime] NULL,
	[DgnLotKey] [bigint] NOT NULL,
	[DgnLotName] [nvarchar](128) NOT NULL,
	[DgnLotOrderItemKey] [bigint] NOT NULL,
	[DgnTobjHistoryKey] [bigint] NOT NULL,
	[DgnWorkOrderKey] [bigint] NOT NULL,
	[DgnWorkOrderNumber] [nvarchar](64) NOT NULL,
	[DgnProductionTeam] [nvarchar](80) NULL,
	[IsDuplicatedCompletion] [varchar](3) NULL,
	[SKCompleteComment] [int] NOT NULL,
	[SKCompleteDate] [int] NOT NULL,
	[SKCompleteTime] [int] NOT NULL,
	[SKCompleteDateUTC] [int] NOT NULL,
	[SKCompleteTimeUTC] [int] NOT NULL,
	[SKCompleteReason] [int] NOT NULL,
	[SKTeamRegion] [int] NOT NULL,
	[SKCompleteUserName] [int] NOT NULL,
	[SKCompletionPass] [int] NOT NULL,
	[SKDoctor] [int] NOT NULL,
	[SKOperation] [int] NOT NULL,
	[SKPart] [int] NOT NULL,
	[SKRoute] [int] NOT NULL,
	[SKRouteStep] [int] NOT NULL,
	[SKStartDate] [int] NOT NULL,
	[SKStartTime] [int] NOT NULL,
	[SKStartUserName] [int] NOT NULL,
	[StartCount] [int] NOT NULL,
	[CompleteCount] [int] NULL,
	[CompleteQuantity] [numeric](23, 9) NULL,
	[StartQuantity] [numeric](23, 9) NULL,
	[StartPauseDuration] [int] NULL,
	[CompletePauseDuration] [int] NULL,
	[ClinCheckStatus] [nvarchar](64) NULL,
	[PostClinCheckFail] [int] NOT NULL,
	[CycleTimeMinutes] [int] NULL,
	[NewTreatmentFlow] [nvarchar](50)NULL
)
WITH (HEAP, DISTRIBUTION = HASH([DgnLotKey]));
GO

CREATE CLUSTERED COLUMNSTORE INDEX [IX_Clus_Colu_FactLotHistory] ON [DWTOPS].[FactLotHistory];

GO
CREATE NONCLUSTERED INDEX [IX_FactLotHistory_SKCompleteDate]
    ON [DWTOPS].[FactLotHistory]([SKCompleteDate] ASC);

