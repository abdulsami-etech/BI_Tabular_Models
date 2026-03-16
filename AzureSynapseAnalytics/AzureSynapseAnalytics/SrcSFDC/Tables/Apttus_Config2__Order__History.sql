
CREATE TABLE [SrcSFDC].[Apttus_Config2__Order__History]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[ParentId] [nchar](18) NOT NULL,
	[CreatedById] [nchar](18) NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[Field] [nvarchar](255) NOT NULL,
	[Id] [nchar](18) NOT NULL,
	[IsDeleted] [bit] NOT NULL,
	[NewValue] [nvarchar](255) NULL,
	[OldValue] [nvarchar](255) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [Id] ),
	CLUSTERED INDEX
	(
		[Id] ASC
	)
)



