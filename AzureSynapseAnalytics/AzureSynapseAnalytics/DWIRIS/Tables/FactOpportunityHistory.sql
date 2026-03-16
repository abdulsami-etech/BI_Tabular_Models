create TABLE [DWIRIS].[FactOpportunityHistory]
(
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NULL,
	[Id] [nchar](18) NOT NULL,
	[SourceSystem] [char](10) NOT NULL,
	[SKOpportunity] [int] NOT NULL,
	[KeyOpportunity] [nvarchar](255) NOT NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[CreatedById] [nchar](18) NULL,
	[Field] [nvarchar](255) NOT NULL,
	[IsDeleted] [varchar](5) NOT NULL,
	[NewValue] [nvarchar](255) NULL,
	[OldValue] [nvarchar](255) NULL,
	[OpportunityId] [nchar](18) NOT NULL
)
WITH (DISTRIBUTION = ROUND_ROBIN, CLUSTERED COLUMNSTORE INDEX)