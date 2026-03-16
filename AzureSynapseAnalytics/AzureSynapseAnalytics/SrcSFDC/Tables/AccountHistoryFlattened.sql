CREATE TABLE [SrcSFDC].[AccountHistoryFlattened] (
    [LZBatchID]           INT            NOT NULL,
    [ADLSBatchID]         INT            NULL,
    [ADLSTimestamp]       DATETIME2 (0)  NULL,
    [ParentId]            NCHAR (18)     NULL,
    [StartDate]           DATE           NULL,
    [EndDate]             DATE           NULL,
    [Account_Status__c]   NVARCHAR (255) NULL,
    [ShippingCountryCode] NVARCHAR (255) NULL,
    [Group_Accounts__c]   NVARCHAR (255) NULL,
	[Type]                NVARCHAR (255) NULL,
	[Account_Sub_Type__c] NVARCHAR (255) NULL,
	[Customer_Group__c]   NVARCHAR (255) NULL,
	[Account_Segmentation__c] NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([ParentId]), DISTRIBUTION = HASH([ParentId]));

