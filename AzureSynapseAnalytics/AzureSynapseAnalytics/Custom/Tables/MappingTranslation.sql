
CREATE TABLE [Custom].[MappingTranslation]
(
	[SourceSystem] [varchar](100) NOT NULL,
	[CaseStatus] [varchar](250) NOT NULL,
	[BusinessTranslation] [varchar](500) NOT NULL,
	[ConsumerApp] [varchar](100) NOT NULL,
	[InternalStatus] [varchar](200) NOT NULL,
	[DoctorStatus] [varchar](200) NOT NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED INDEX
	(
		[SourceSystem] ASC,
		[CaseStatus] ASC
	)
)



