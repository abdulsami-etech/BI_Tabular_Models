
CREATE TABLE [DW].[DimCampaignMember] (
    [SKCampaignMember]           INT            NOT NULL,
    [ADLSBatchID]          INT            NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)  NOT NULL,
    [LZBatchID]            INT            NOT NULL,
    [DWBatchID]            INT            NOT NULL,
    [DWHash]               CHAR (40)      NOT NULL,
    [KeyCampaignMember]    NCHAR (18)     NOT NULL,

    [CampaignId]							nvarchar(18)		NOT NULL,
	[City]									nvarchar(40)		NULL,
	[CompanyOrAccount]						nvarchar(255)		NULL,
	[ContactId]								nvarchar(18)		NULL,
	[Country]								nvarchar(80)		NULL,
	[CreatedByRole]							nvarchar(1300)		NULL,
	[CreatedByUser]							nvarchar(1300)		NULL,
	[CreatedById]							nvarchar(18)		NULL,
	[CreatedDate]							datetime2(7)		NULL,
	[CurrencyIsoCode]						nvarchar(3)			NULL,
	[DID]									nvarchar(50)		NULL,
	[DIDNumber]								nvarchar(50)		NULL,
	[Email]									nvarchar(80)		NULL,
	[FirstName]								nvarchar(40)		NULL,
	[FirstRespondedDate]					datetime2(7)		NULL,
	[IsAttended]							nvarchar(5)			NULL,
	[IsDeleted]								nvarchar(5)			NULL,
	[LastModifiedById]						nvarchar(18)		NULL,
	[LastModifiedDate]						datetime2(7)		NULL,
	[LastName]								nvarchar(80)		NULL,
	[LeadId]								nvarchar(18)		NULL,
	[LeadOrContactId]						nvarchar(18)		NULL,
	[LeadOrContactOwnerId]					nvarchar(18)		NULL,
	[LeadSource]							nvarchar(80)		NULL,
	[Name]									nvarchar(255)		NULL,
	[OriginalType]							nvarchar(50)		NULL,
	[RecordTypeId]							nvarchar(18)		NULL,
	[Status]								nvarchar(40)		NULL,
	[StatusReason]							nvarchar(255)		NULL,
	[SystemModstamp]						datetime2(7)		NULL,
	[Type]									nvarchar(40)		NULL

   ,[SecRegion]								VARCHAR (10)		DEFAULT ('') NOT NULL
   
    CONSTRAINT [PK_DimCampaignMember] PRIMARY KEY NONCLUSTERED ([SKCampaignMember] ASC) NOT ENFORCED,
    CONSTRAINT [UQ_DimCampaignMember_KeyCampaignMember] UNIQUE NONCLUSTERED ([KeyCampaignMember] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([SKCampaignMember]), DISTRIBUTION = HASH([SKCampaignMember]));

