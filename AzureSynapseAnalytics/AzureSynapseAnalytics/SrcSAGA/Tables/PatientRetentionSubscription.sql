CREATE TABLE [SrcSAGA].[PatientRetentionSubscription]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[PackageId] [uniqueidentifier] NOT NULL,
	[ClinId] [varchar](64) NOT NULL,
	[PaymentFrequency] [varchar](32) NOT NULL,
	[Status] [varchar](32) NOT NULL,
	[UserId] [uniqueidentifier] NULL,
	[LeadId] [varchar](64) NULL,
	[StartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[CancelledDate] [datetime2](7) NULL,
	[RenewalDate] [datetime2](7) NULL,
	[OptOutDate] [datetime2](7) NULL,
	[ExternalSubscriptionReference] [varchar](64) NULL,
	[SubscriptionDateCreated] [datetime2](7) NOT NULL,
	[SubscriptionDateUpdated] [datetime2](7) NOT NULL,
	[PaymentFlag] [bit] NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[SubscriptionId] ASC
	)
);


