CREATE TABLE [DW].[FactPipeline] (
[DWBatchID]                				INT            		NOT NULL,
[DWHashKey]								CHAR(40)			NOT NULL,
[SAPOrderNumber]						BIGINT 				NOT NULL,
[DateKey]								DATE 				NULL,
[StatusDate]							DATE 				NULL,
[SKOrderStatus]							INT 				NOT NULL,
[SKContact]                       		INT            		NOT NULL,
[SKOrder]          						BIGINT       		NOT NULL,
[SecRegion]								NVARCHAR(10) 		NULL,
[SKAccountSoldTo]                		INT            		NOT NULL,
[TreatmentOption]						NVARCHAR(225) 		NULL,
[DeliverableType]						NVARCHAR(225) 		NULL,
[ProfitCenter] 							NVARCHAR(10) 		NULL,
[CCAAAging]                				INT            		NULL,
[BatchID]                				INT            		NOT NULL,
[CreatedDate]							DATETIME	   		NULL,
[ModifiedDate]							DATETIME	   		NULL	
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH (SAPOrderNumber));