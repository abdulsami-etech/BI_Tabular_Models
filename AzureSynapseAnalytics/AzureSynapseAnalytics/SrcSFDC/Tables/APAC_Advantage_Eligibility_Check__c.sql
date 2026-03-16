CREATE TABLE [SrcSFDC].[APAC_Advantage_Eligibility_Check__c] (
    [LZBatchID]                           INT            NOT NULL,
    [ADLSBatchID]                         INT            NOT NULL,
    [ADLSTimestamp]                       DATETIME2 (0)  NOT NULL,
    [Account_Type__c]                     NVARCHAR (255) NULL,
    [Channel__c]                          NVARCHAR (80)  NULL,
    [Country_Code__c]                     NVARCHAR (2)   NULL,
    [CreatedById]                         NCHAR (18)     NULL,
    [CreatedDate]                         DATETIME2 (7)  NOT NULL,
    [CurrencyIsoCode]                     NVARCHAR (3)   NOT NULL,
    [Doctor__c]                           BIT            NULL,
    [Id]                                  NCHAR (18)     NOT NULL,
    [IsDeleted]                           BIT            NOT NULL,
    [LastModifiedById]                    NCHAR (18)     NULL,
    [LastModifiedDate]                    DATETIME2 (7)  NOT NULL,
    [Line_of_Business__c]                 NVARCHAR (255) NULL,
    [Loyalty_Code__c]                     NVARCHAR (10)  NULL,
    [Name]                                NVARCHAR (38)  NOT NULL,
    [Pricing_Group_Sold_To__c]            BIT            NULL,
    [Pricing_Group_Treatment_Location__c] BIT            NULL,
    [SetupOwnerId]                        NCHAR (18)     NULL,
    [Sold_To__c]                          BIT            NULL,
    [SystemModstamp]                      DATETIME2 (7)  NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

