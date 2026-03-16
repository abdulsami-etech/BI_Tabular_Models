CREATE TABLE [DW].[FactTrainingEvents](
	[Id] 							[NVARCHAR](18) 		NOT NULL,
	[DWBatchID] 					[INT] 				NOT NULL,
	[DWHash]                   		[CHAR] (40)      	NOT NULL,
	[EventID] 						[NCHAR](18) 		NOT NULL,
	[EventName] 					[NVARCHAR](60) 		NULL,
	[EventCity] 					[NVARCHAR](80) 		NULL,
	[EventState] 					[NVARCHAR](80) 		NULL,
	[EventCountry] 					[NVARCHAR](40) 		NULL,
	[SKTrainingEventType] 			[INT] 				NOT NULL,
	-- [CustomerKey] 					[INT] 				NOT NULL,
	[SKAccount] 					[INT] 				NOT NULL,
	[SKContact] 					[INT] 				NOT NULL,
	[EventDate] 					[DATE]				NOT NULL,
	[EventLocationID] 				[NVARCHAR](18) 		NULL,
	[SpeakerName] 					[NVARCHAR](60) 		NULL,
	[CEHours] 						[INT] 				NULL,
	[EventLocationName] 			[NVARCHAR](50) 		NULL,
	[TuitionFee] 					[DECIMAL](15, 2) 	NULL,
	[IsPointsAccrued] 				[NVARCHAR](3) 		NULL,
	[IsPromotionEligible] 			[NVARCHAR](3) 		NULL,
	[IsAttended] 					[INT] 				NULL,
	[LastModifiedDate] 				[DATETIME2](7) 		NOT NULL,
	[StudyClubCode] 				[NVARCHAR](30) 		NULL,
	[CreatedDate] 					[DATETIME2](0)		NOT NULL,
	[ModifiedDate] 					[DATETIME2](0)		NOT NULL,
	 CONSTRAINT PK_FactTrainingEvents PRIMARY KEY nonclustered (Id) not enforced
)	
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Id]));
GO


