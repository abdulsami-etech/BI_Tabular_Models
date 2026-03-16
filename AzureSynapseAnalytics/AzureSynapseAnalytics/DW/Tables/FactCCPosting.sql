CREATE TABLE [DW].[FactCCPosting] (
[DWBatchID]                				INT            		NOT NULL,
[DWHashKey]								CHAR(40)			NOT NULL,
[SAPOrderNumber]            			VARCHAR (64)  		NOT NULL,
[SAPTreatmentOption]            		NVARCHAR(30)		NULL,
[CountryCode]							VARCHAR(10) 		NULL,
[SAPDeliverableType]					NVARCHAR(30)		NULL,
[ProductHierarchy]						NVARCHAR(50) 		NULL,
[CCPostingDate]							DATE 				NULL,
[TreatmentCategory]						NVARCHAR(15)   		NOT NULL,
[CreatedDate]							DATETIME	   		NULL,
[ModifiedDate]							DATETIME	   		NULL	
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrderNumber]));


