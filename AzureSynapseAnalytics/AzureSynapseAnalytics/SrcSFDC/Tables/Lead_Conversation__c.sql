CREATE TABLE [SrcSFDC].[Lead_Conversation__c]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Case__c] [nchar](36) NULL,
	[ConnectionReceivedId] [nchar](36) NULL,
	[ConnectionSentId] [nchar](36) NULL,
	[Consumer_Country_Twilio_Number__c] [nvarchar](510) NULL,
	[Consumer_Lead__c] [nchar](36) NULL,
	[Consumer_phone_number__c] [nvarchar](510) NULL,
	[Contact__c] [nchar](36) NULL,
	[Conversation__c] [nvarchar](max) NULL,
	[CreatedById] [nchar](36) NULL,
	[CreatedDate] [datetime2](7) NULL,
	[CurrencyIsoCode] [nvarchar](6) NULL,
	[Id] [nchar](36) NOT NULL,
	[IsDeleted] [varchar](5) NULL,
	[LastModifiedById] [nchar](36) NULL,
	[LastModifiedDate] [datetime2](7) NULL,
	[Name] [nvarchar](160) NULL,
	[OwnerId] [nchar](36) NULL,
	[SMS_Conversation__c] [varchar](5) NULL,
	[SystemModstamp] [datetime2](7) NULL,
	[WhatsApp_Conversation__c] [varchar](5) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Id] ),
	CLUSTERED INDEX
	(
		[Id] ASC
	)
)

