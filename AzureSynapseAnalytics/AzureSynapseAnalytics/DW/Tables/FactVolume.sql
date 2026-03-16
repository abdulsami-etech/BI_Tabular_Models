CREATE TABLE [DW].[FactVolume] (
[DWBatchID]                				INT            		NOT NULL,
[DWHashKey]								CHAR(40)			NOT NULL,
[DWHash]								CHAR(40)			NOT NULL,
[SAPOrderNumber]						BIGINT 				NOT NULL,
[IDSOrderNumber]						INT            		NULL,
[IsKeyStatus]							BIT					NULL,
[SKOrderStatus]							INT 				NOT NULL,
[SKContact]                       		INT            		NOT NULL,
[SKOrder]          						BIGINT       		NOT NULL,
[SKAccountSoldTo]                		INT            		NOT NULL,
[SKAccountShipTo]                		INT            		NOT NULL,
[SKAccountTreatmentLocation]            INT            		NOT NULL,
[StatusDate]							DATE 				NULL,
[CountryCode]							NVARCHAR(10) 		NULL,
[SecRegion]								NVARCHAR(10) 		NULL,
[PatientSFID]							NCHAR(18) 			NULL,
[NewOrRestart]							NVARCHAR(10) 		NULL,
[Plant]									NVARCHAR(4) 		NULL,
[ReceiptDate]							DATE 				NULL,
[ProductHierarchy]						NVARCHAR(50) 		NULL,
[TreatmentOption]						NVARCHAR(225) 		NULL,
[DeliverableType]						NVARCHAR(225) 		NULL,
[TreatmentCategory]						NVARCHAR(255) 		NULL,
[MaterialNumber] 						INT					NULL,
[ProfitCenter] 							INT					NULL,
[ContactNumber] 						NVARCHAR(1300) 		NULL,
[ProfCat] 								NVARCHAR(255) 		NULL,
[TreatmentID] 							NVARCHAR(1300) 		NULL,
[SoldTo] 								NVARCHAR(1300) 		NULL,
[ShipTo] 								NVARCHAR(1300) 		NULL,
[TreatmentLocation] 					NVARCHAR(40) 		NULL,
[ItemCategory]							NVARCHAR (4)        NULL,
[ClinID]                          		NVARCHAR (50)  		NULL,
[SFOrderId]                             NCHAR (18)          NULL,
[SFOrderNumber]                         NVARCHAR (80)       NULL,
[IsDSO]                         		VARCHAR (5)       	NULL,
[TotalAlignerQuantity]					INT 				NULL,
[DeliverableQuantity]					INT 				NULL,
[StatusCount]							INT 				NULL,
[MinStatusDate]							DATETIME	   		NULL,
[MaxStatusDate]							DATETIME	   		NULL,
[ADLSTimestamp]							DATETIME2 (0) 	   	NULL,
[InsertedFromSource]					NVARCHAR(40) 		NULL,
[UpdatedFromSource]						NVARCHAR(40) 		NULL,
[CreatedDate]							DATETIME2 (0)	   	NULL,
[ModifiedDate]							DATETIME2 (0)	   	NULL,
[_Region]								VARCHAR(32)			NULL	
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH (SAPOrderNumber))
GO

CREATE STATISTICS STATS_DW_FactVolume_DWHash ON [DW].[FactVolume] (DWHash)
GO
CREATE STATISTICS STATS_DW_FactVolume_DWHashKey ON [DW].[FactVolume] (DWHashKey)
GO
CREATE STATISTICS STATS_DW_FactVolume_SKOrderStatus ON [DW].[FactVolume] (SKOrderStatus)
GO