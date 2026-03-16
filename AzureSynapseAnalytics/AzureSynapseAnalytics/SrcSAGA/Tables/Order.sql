CREATE TABLE [SrcSAGA].[Order]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[SAPOrderNumber] [bigint] NOT NULL,
	[SFDCId] [char](18) NOT NULL,
	[ContractNumber] [varchar](16) NOT NULL,
	[ClinId] [varchar](64) NOT NULL,
	[SoldTo] [varchar](64) NOT NULL,
	[TreatmentOption] [varchar](128) NOT NULL,
	[DeliverableType] [varchar](128) NOT NULL,
	[OrderDate] [datetime2](6) NOT NULL,
	[CancellationDate] [datetime2](6) NULL,
	[PatientSFDCId] [char](18) NOT NULL,
	[NumberOfAlignersUsed] [int] NOT NULL,
	[DateCreated] [datetime2](7) NOT NULL,
	[DateUpdated] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[SAPOrderNumber] ASC
	)
);


