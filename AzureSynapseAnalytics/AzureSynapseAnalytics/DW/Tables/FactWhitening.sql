CREATE TABLE [DW].[FactWhitening] (
[DWBatchID]                				INT            		NOT NULL,
[SKOrder]								BIGINT				NOT NULL,
[SAPOrderNumber]						BIGINT 				NOT NULL,
[MaterialNumber]						NVARCHAR (1300) 	NULL,
[LineNumber]							DECIMAL (18)    	NULL,
[PatientAge]							DECIMAL (18) 		NULL,
[Product]							 	NVARCHAR (255)		NOT NULL,
[DeliverableType]                       NVARCHAR (255)		NULL,
[IncentiveCode]          				NVARCHAR (255)		NULL,
[AMRTerritoryCode]						NVARCHAR (255) 		NULL,
[CCATerritoryCode]                		NVARCHAR (255) 		NULL,
[ListPrice]								DECIMAL (18, 5) 	NULL,
[NetPrice]								DECIMAL (18, 5) 	NULL,
[DiscAmount] 							DECIMAL (18, 2) 	NULL,
[DiscPerc]                				DECIMAL (18, 2) 	NULL,
[SecRegion]                				VARCHAR (10)   		NULL,
[Quantity]								DECIMAL (18, 5) 	NULL,
[DeliverableQty]    					DECIMAL (18)    	NULL,
[CreatedDate]							DATETIME	   		NULL,
[ModifiedDate]							DATETIME	   		NULL	
)
WITH (CLUSTERED INDEX([SKOrder]), DISTRIBUTION = ROUND_ROBIN);