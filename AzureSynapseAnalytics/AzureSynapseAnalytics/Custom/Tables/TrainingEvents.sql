CREATE TABLE [Custom].[TrainingEvents](
	[TrainingEventCode] 					[NVARCHAR](10)	 	NOT NULL,
	[TrainingEventName] 					[NVARCHAR](50) 		NOT NULL,
	[ProfEdEventType] 						[NVARCHAR](50) 		NULL,
	[CustomerAddressListExtendedGrouping] 	[NVARCHAR](50) 		NULL,
	[AudienceType] 							[NVARCHAR](10)		NULL,
	[NewTraining] 							[BIT] 				DEFAULT ((0))NULL
)
WITH (CLUSTERED INDEX( [TrainingEventCode] ASC ), DISTRIBUTION = REPLICATE);
