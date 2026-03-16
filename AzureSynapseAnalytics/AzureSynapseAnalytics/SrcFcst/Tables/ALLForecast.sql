CREATE TABLE [SrcFcst].[ALLForecast]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Scenario] [varchar](100) NOT NULL,
	[CountryGroup] [varchar](100) NOT NULL,
	[Measure] [varchar](50) NOT NULL,
	[PeriodType] [varchar](50) NOT NULL,
	[PeriodDate] [date] NOT NULL,
	[Channel] [varchar](50) NULL,
	[Value] [decimal](18, 9) NULL,
	[TreatmentType] [varchar](50) NULL,
	[ProfitCenter] [varchar](50) NULL,
	[LoadDate] [datetime] NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)


