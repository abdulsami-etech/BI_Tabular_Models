CREATE TABLE [SrcSFDC].[Event__c]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[AGD_Pace__c] [varchar](5) NULL,
	[CE_Hours__c] [decimal](18, 0) NULL,
	[ConnectionReceivedId] [nchar](18) NULL,
	[ConnectionSentId] [nchar](18) NULL,
	[CreatedById] [nchar](18) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[CurrencyIsoCode] [nvarchar](3) NOT NULL,
	[Id] [nchar](18) NOT NULL,
	[IsDeleted] [varchar](5) NOT NULL,
	[LastModifiedById] [nchar](18) NULL,
	[LastModifiedDate] [datetime2](7) NOT NULL,
	[LastReferencedDate] [datetime2](7) NULL,
	[LastViewedDate] [datetime2](7) NULL,
	[Name] [nvarchar](80) NULL,
	[OwnerId] [nchar](18) NOT NULL,
	[Post_course_Module_Link__c] [nvarchar](255) NULL,
	[Pre_course_Module_Link__c] [nvarchar](255) NULL,
	[Product_Code__c] [nvarchar](25) NULL,
	[Subject_Code__c] [nvarchar](255) NULL,
	[SystemModstamp] [datetime2](7) NOT NULL,
	[Training_Code__c] [nvarchar](10) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)
GO


