CREATE TABLE [SrcSFMC].[Email_Send_Log] (
    [LZBatchID]               INT            NOT NULL,
    [ADLSBatchID]             INT            NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)  NOT NULL,
    [JobID]                   INT            NOT NULL,
    [ListID]                  INT            NOT NULL,
    [BatchID]                 INT            NOT NULL,
    [SubID]                   INT            NOT NULL,
    [TriggeredSendID]         NVARCHAR (255) NULL,
    [ErrorCode_]              NVARCHAR (255) NULL,
    [Datetime]                NVARCHAR (255) NULL,
    [MailingCountryCode]      NVARCHAR (255) NULL,
    [acc_Billing_Language__c] NVARCHAR (255) NULL,
    [acc_ShippingCity]        NVARCHAR (255) NULL,
    [CountryRegion]           NVARCHAR (255) NULL,
    [OwnerName]               NVARCHAR (255) NULL,
    [SubscriberKey]           NVARCHAR (255) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

