CREATE TABLE [SrcSFDC].[Apttus_Config2__PriceListItem__c] (
    [LZBatchID]                      INT             NOT NULL,
    [ADLSBatchID]                    INT             NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0)   NOT NULL,
    [Apttus_Config2__Active__c]      BIT             NULL,
    [Apttus_Config2__ChargeType__c]  NVARCHAR (255)  NULL,
    [Apttus_Config2__ListPrice__c]   DECIMAL (18, 5) NULL,
    [Apttus_Config2__PriceListId__c] NCHAR (18)      NULL,
    [Apttus_Config2__ProductId__c]   NCHAR (18)      NULL,
    [Id]                             NCHAR (18)      NOT NULL,
    [IsDeleted]                      BIT             NOT NULL,
    [LastModifiedDate]               DATETIME2 (7)   NOT NULL,
    [SystemModstamp]                 DATETIME2 (7)   NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = ROUND_ROBIN);

