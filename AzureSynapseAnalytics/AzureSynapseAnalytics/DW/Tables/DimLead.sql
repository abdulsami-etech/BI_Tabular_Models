CREATE TABLE [DW].[DimLead]
(
     [SKLead]                INT            NOT NULL
    ,[ADLSBatchID]           INT            NOT NULL
    ,[ADLSTimestamp]         DATETIME2 (0)  NOT NULL
    ,[LZBatchID]             INT            NOT NULL
    ,[DWBatchID]             INT            NOT NULL
    ,[DWHash]                CHAR (40)      NOT NULL
    ,[KeyLead]               NCHAR (18)     NOT NULL

    ,[AccountID]	                NCHAR(18)	    NULL
    ,[AccountRegion]	            NVARCHAR(100)	NULL
    ,[AccountCity]	                NVARCHAR(200)	NULL
    ,[AccountPostalCode]	        NVARCHAR(100)	NULL
    ,[AccountState]	                NVARCHAR(100)	NULL
    ,[AccountSubTypeLookup]	        NVARCHAR(100)	NULL
    ,[AccountType]	                NVARCHAR(100)	NULL
    ,[AdaptEligible]	            VARCHAR(5)	    NULL
    ,[Address1]	                    NVARCHAR(70)	NULL
    ,[Address2]	                    NVARCHAR(70)	NULL
    ,[Address3]	                    NVARCHAR(70)	NULL
    ,[Address4]	                    NVARCHAR(70)	NULL
    ,[AddressType]	                NVARCHAR(70)	NULL
    ,[Age]	                        DECIMAL(18,0)	NULL
    ,[ASD]	                        NVARCHAR(100)	NULL
    ,[CCAAchieved]	                VARCHAR(5)	    NULL
    ,[CCAPatientCount]	            DECIMAL(18,7)	NULL
    ,[City]	                        NVARCHAR(80)	NULL
    ,[CCADate]	                    DATE	        NULL
    ,[ClinID]	                    NVARCHAR(80)	NULL
    ,[Comments]	                    NVARCHAR(510)	NULL
    ,[Company]	                    NVARCHAR(150)	NULL
    ,[ConditionType]	            NVARCHAR(100)	NULL
    ,[ConsultAchieved]	            VARCHAR(5)	    NULL
    ,[ConsultDate]	                DATE	        NULL
    ,[ConsultType]	                NVARCHAR(100)	NULL
    ,[Converted]	                VARCHAR(5)	    NULL
    ,[ConvertedDate]	            DATE	        NULL
    ,[ConvertedToPatient]	        VARCHAR(5)	    NULL
    ,[ConvertedToPatientOrCCA]	    VARCHAR(5)	    NULL
    ,[Country]	                    NVARCHAR(100)	NULL
    ,[CountryCode]	                NVARCHAR(20)	NULL
    ,[CreatedDate]	                DATE	        NULL
    ,[CreatedByID]	                NCHAR(18)	    NULL
    ,[DaysFromCheckInToCCA]	        DECIMAL(18,0)	NULL
    ,[DaysFromConsultToCCA]	        DECIMAL(18,0)	NULL
    ,[DaysFromFirstContactToConsult] DECIMAL(18,0)	NULL
    ,[DaysFromScheduledtoConsult]	 DECIMAL(18,0)	NULL
    ,[DaysToCCAFromFrstContact]	     DECIMAL(18,0)	NULL
    ,[DaysToCloseFromConsult]	     DECIMAL(18,0)	NULL
    ,[DaysToConvertFromConsult]	     DECIMAL(18,0)	NULL
    ,[DaystoConvertFromFirstContact] DECIMAL(18,0)	NULL
    ,[DID]	                         NVARCHAR(100)	NULL
    ,[DIDNumber]	                DECIMAL(18,0)	NULL
    ,[Finance]	                    NVARCHAR(10)	NULL
    ,[FirstContactDate]	            DATE	        NULL
    ,[Gender]	                    NVARCHAR(20)	NULL
    ,[HasOptedOutOfEmail]	        VARCHAR(5)	    NULL
    ,[Iam]	                        NVARCHAR(200)	NULL
    ,[IsConverted]	                VARCHAR(5)	    NULL
    ,[LeadScore]	                DECIMAL(18,0)	NULL
    ,[LeadURLCampaign]	            NVARCHAR(200)	NULL
    ,[LeadURLMedium]	            NVARCHAR(200)	NULL
    ,[LeadURLSource]	            NVARCHAR(200)	NULL
    ,[LeadURLTerm]	                NVARCHAR(200)	NULL
    ,[LeadSource]	                NVARCHAR(80)	NULL
    ,[OwnerID]	                    NCHAR(18)	    NULL
    ,[PatientID]	                NCHAR(18)	    NULL
    ,[PCSTerritory]	                NVARCHAR(200)	NULL
    ,[PCSTerritoryAgent]	        NVARCHAR(160)	NULL
    ,[PrimaryGoal]	                NVARCHAR(200)	NULL
    ,[ProspectID]	                NVARCHAR(60)	NULL
    ,[ProspectStatus]	            NVARCHAR(160)	NULL
    ,[RecordType]	                NVARCHAR(100)	NULL
    ,[SmileVisualization]	        VARCHAR(5)	    NULL
    ,[SmileView]	                VARCHAR(5)	    NULL
    ,[State]	                    NVARCHAR(160)	NULL
    ,[Status]	                    NVARCHAR(80)	NULL
    ,[TestLead]	                    VARCHAR(5)	    NULL
    ,[ZIP]	                        NVARCHAR(40)	NULL
    ,[LeadRegion]	                NVARCHAR(100)	NULL
    ,[HasOptedOutOfMobile]	        NVARCHAR(10)	NULL
    ,[SecRegion]                    VARCHAR (10)    NULL

)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SKLead]));