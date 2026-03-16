CREATE TABLE [SrcSAGA].[PatientRetentionQuote]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[QuoteId] [uniqueidentifier] NOT NULL,
	[DoctorId] [uniqueidentifier] NOT NULL,
	[ClinId] [varchar](64) NOT NULL,
	[Email] [varchar](128) NULL,
	[DoctorMessage] [nvarchar](4000) NULL,
	[Status] [varchar](32) NOT NULL,
	[RejectReason] [varchar](64) NULL,
	[UserId] [uniqueidentifier] NULL,
	[LeadId] [varchar](64) NULL,
	[ExpiredAt] [datetime2](7) NULL,
	[ExternalQuoteReference] [varchar](64) NULL,
	[QuoteCreatedDate] [datetime2](7) NOT NULL,
	[QuoteUpdatedDate] [datetime2](7) NOT NULL,
	[ValidFrom] [datetime2](7) NOT NULL,
	[ValidTo] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[QuoteId] ASC
	)
);


