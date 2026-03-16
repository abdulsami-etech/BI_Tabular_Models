CREATE TABLE [SrcSAGA].[Subscription]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[ContractNumber] [varchar](16) NOT NULL,
	[LastAction] [varchar](32) NOT NULL,
	[ClinId] [varchar](64) NOT NULL,
	[SoldTo] [varchar](32) NOT NULL,
	[ContractStartDate] [date] NOT NULL,
	[ContractEndDate] [date] NOT NULL,
	[LastRequestDate] [datetime2](7) NOT NULL,
	[ProgramCode] [varchar](32) NOT NULL,
	[PackageCode] [varchar](32) NOT NULL,
	[PackageName] [varchar](64) NOT NULL,
	[PricePerAligner] [numeric](10, 2) NOT NULL,
	[AlignerPerMonth] [int] NOT NULL,
	[ContractTermLength] [int] NOT NULL,
	[Allowance] [varchar](32) NOT NULL,
	[CancellationDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[ContractNumber] ASC
	)
);


