CREATE TABLE [DW].[DimSharedContact](
	[SKAccount] 			[INT] 				NOT NULL,
	[KeyAccount]            [NCHAR] (18)     	NOT NULL,
	[DWBatchId] 			[INT] 				NOT NULL,
	[DWHash]    			[CHAR] (40)      	NOT NULL,
	[AccountNumber]     	[NVARCHAR] (1300) 	NULL,
	[KeyContact]            [NCHAR] (18)     	NOT NULL,
	[SKContact] 			[INT] 				NOT NULL,
	[LastModifiedDate]      [DATETIME2] (7)   	NOT NULL,
	[SecRegion]             [VARCHAR] (10)   	NULL,
	[CreatedDate] 			[DATETIME2](0)		NOT	 NULL,
	[ModifiedDate] 			[DATETIME2](0)		NOT	 NULL
)
WITH (CLUSTERED INDEX([SKAccount]), DISTRIBUTION = REPLICATE);
