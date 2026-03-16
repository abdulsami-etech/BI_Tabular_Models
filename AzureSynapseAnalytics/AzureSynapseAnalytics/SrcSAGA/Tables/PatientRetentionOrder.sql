CREATE TABLE [SrcSAGA].[PatientRetentionOrder]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[OrderId] [int] NOT NULL,
	[SubscriptionId] [uniqueidentifier] NULL,
	[IDSPatientId] [int] NOT NULL,
	[SAPOrderNumber] [bigint] NULL,
	[OrderType] [varchar](128) NOT NULL,
	[SubmissionType] [varchar](128) NOT NULL,
	[SubmittedBy] [varchar](128) NOT NULL,
	[SubmissionDate] [datetime2](7) NULL,
	[AMRDate] [datetime2](7) NULL,
	[CCADate] [datetime2](7) NULL,
	[CancellationDate] [datetime2](7) NULL,
	[ShipmentDate] [datetime2](7) NULL,
	[ShipmentTrackingNumber] [varchar](128) NULL,
	[ShippingProvider] [varchar](128) NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[OrderId] ASC
	)
);


