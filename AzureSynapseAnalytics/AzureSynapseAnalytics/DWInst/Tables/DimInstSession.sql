CREATE TABLE [DWInst].[DimInstSession]
(
	[session_id] [uniqueidentifier] NOT NULL,
	[DWBatchID] [int] NULL,
	[ADLSTimestamp] [datetime2](7) NULL,
	[WandVersion] [varchar](4000) NULL,
	[RxId] [varchar](4000) NULL,
	[ScanDate] [varchar](4000) NULL,
	[CaseType] [varchar](4000) NULL,
	[FirewallInfo] [varchar](4000) NULL,
	[StillTimeInSeconds] [varchar](4000) NULL,
	[SessionTime] [datetime] NULL,
	[sessionDate] [date] NULL,
	[DoctorName] [varchar](4000) NULL,
	[OcclusionColors] [varchar](4000) NULL,
	[ComputerName] [varchar](4000) NULL,
	[CrownInstallDate] [varchar](4000) NULL,
	[WandId] [varchar](4000) NULL,
	[CompanyId] [varchar](4000) NULL,
	[DoctorId] [varchar](4000) NULL,
	[InternetExplorerVersion] [varchar](4000) NULL,
	[InstrumentationCaseId] [varchar](4000) NULL,
	[CaseTypeId] [varchar](4000) NULL,
	[ApplicationName] [varchar](4000) NULL,
	[ApplicationVersion] [varchar](4000) NULL,
	[ApplicationLanguage] [varchar](4000) NULL,
	[ClinicianId] [varchar](4000) NULL,
	[DurationInMinutes] [int] NULL
)
WITH
(
	DISTRIBUTION = HASH ( [session_id] ),
	HEAP
)



