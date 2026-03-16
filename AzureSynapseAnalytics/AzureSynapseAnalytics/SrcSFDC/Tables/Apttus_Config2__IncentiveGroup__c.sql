CREATE TABLE [SrcSFDC].[Apttus_Config2__IncentiveGroup__c]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Apttus_Config2__Description__c] [nvarchar](255) NULL,
	[ConnectionReceivedId] [nchar](18) NULL,
	[ConnectionSentId] [nchar](18) NULL,
	[CreatedById] [nchar](18) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[CurrencyIsoCode] [nvarchar](3) NOT NULL,
	[Id] [nchar](18) NOT NULL,
	[IsDeleted] [varchar](5) NOT NULL,
	[LastActivityDate] [datetime2](7) NULL,
	[LastModifiedById] [nchar](18) NULL,
	[LastModifiedDate] [datetime2](7) NOT NULL,
	[LastReferencedDate] [datetime2](7) NULL,
	[LastViewedDate] [datetime2](7) NULL,
	[Name] [nvarchar](80) NULL,
	[OwnerId] [nchar](18) NOT NULL,
	[SAP_Pricing_Condition__c] [nvarchar](255) NULL,
	[SystemModstamp] [datetime2](7) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Id] ),
	CLUSTERED INDEX
	(
		[Id] ASC
	)
)