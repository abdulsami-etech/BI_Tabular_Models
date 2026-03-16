CREATE TABLE [DW].[CaseStateHistorySummary]
(
	[DWBatchID] [int] NOT NULL,
	[SAPOrderNumber] [bigint] NOT NULL,
	[ClinID] [varchar](80) NULL,
	[Validated] [int] NOT NULL,
	[DetailStatus] [varchar](100) NULL,
	[DetailStatusBusinessTranslation] [varchar](500) NULL,
	[AggregateStatus] [varchar](200) NULL,
	[DoctorStatus] [varchar](200) NULL,
	[StartTime_UTC] [datetime] NULL,
	[EndTime_UTC] [datetime] NULL,
	[SequenceNumber] [bigint] NULL,
	[NumberofTimesInOperation] [int] NULL,
	[QueueName] [varchar](200) NULL,
	[OperationTimeInMinutes] [int] NULL,
	[OperationDeviationInMinutes] [int] NULL,
	[StatusIndicatorOfTimeSpentInCurrentStep] [int] NULL,
	[QueueTimeinMinutes] [int] NULL,
	[QueueDeviationInMinutes] [int] NULL,
	[StatusIndicatorOfTimespentInPreviousQueue] [int] NULL,
	[RecordLevel] [int] NOT NULL,
	[SourceSystem] [varchar](16) NULL,
	[SKCaseStateStatistic] [int] NULL,
	[EECDDate] [datetime] NULL,
	[CCDDate] [datetime] NULL,
	[HistoryKey] [bigint] NULL
)
WITH
(
	DISTRIBUTION = HASH ( [SAPOrderNumber] ),
	CLUSTERED COLUMNSTORE INDEX
)



