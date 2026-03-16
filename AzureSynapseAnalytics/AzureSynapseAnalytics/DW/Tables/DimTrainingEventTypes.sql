CREATE TABLE [DW].[DimTrainingEventTypes](
	[SKTrainingEventType] 					[INT] 					NOT NULL,
	[KeyTrainingEventType] 					[NVARCHAR](18) 			NOT NULL,
	[DWBatchId] 							[INT] 					NOT NULL,
	[DWHash]                   				[CHAR] (40)      		NOT NULL,
	[TrainingEventTypeCode] 				[NVARCHAR](10) 			NOT NULL,
	[TrainingEventTypeName] 				[NVARCHAR](50) 			NOT NULL,
	[ProfEdEventType] 						[NVARCHAR](50) 			NULL,
	[CustomerAddressListExtendedGrouping] 	[NVARCHAR](50) 			NULL,
	[AudienceType] 							[NVARCHAR](10) 			NULL,
	[NewTraining] 							[NVARCHAR](3) 			NOT NULL,
	[CreatedDate] 							[DATETIME2](0)			NOT NULL,
	[ModifiedDate] 							[DATETIME2](0)			NOT NULL
)
WITH (CLUSTERED INDEX([SKTrainingEventType]), DISTRIBUTION = REPLICATE);


