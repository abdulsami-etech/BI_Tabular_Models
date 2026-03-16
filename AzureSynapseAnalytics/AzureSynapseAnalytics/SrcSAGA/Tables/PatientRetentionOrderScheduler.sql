CREATE TABLE [SrcSAGA].[PatientRetentionOrderScheduler]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[OrderSchedulerId] [int] NOT NULL,
	[SubscriptionId] [uniqueidentifier] NOT NULL,
	[OrderId] [int] NULL,
	[IsFirstManualOrder] [bit] NOT NULL,
	[OrderSetNumber] [int] NOT NULL,
	[NextShipmentDate] [datetime2](7) NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[OrderSchedulerId] ASC
	)
);