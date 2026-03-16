CREATE TABLE [SrcSAGA].[PatientRetentionPackage]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[PackageId] [uniqueidentifier] NOT NULL,
	[QuoteId] [uniqueidentifier] NOT NULL,
	[NumberOfSets] [int] NOT NULL,
	[MonthlyPaymentAmount] [numeric](18, 2) NOT NULL,
	[AnnualPaymentAmount] [numeric](18, 2) NOT NULL,
	[DownPaymentAmount] [numeric](18, 2) NULL,
	[IsRecommended] [bit] NOT NULL,
	[PackageType] [varchar](64) NULL,
	[DeliveryFrequency] [int] NULL,
	[ExternalPackageReference] [varchar](64) NULL,
	[PackageCreatedDate] [datetime2](7) NOT NULL,
	[PackageUpdatedDate] [datetime2](7) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[PackageId] ASC
	)
);


