CREATE TABLE [DWIRIS].[HubServiceContract]
(
	[SKServiceContract] [int] IDENTITY(1,1) NOT NULL,
	[KeyServiceContract] [nvarchar](255) NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[InsertDateTime] [datetime] NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[KeyServiceContract] ASC
	)
)