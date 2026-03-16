CREATE TABLE [DW].[HubPromotion]
(
	[SKPromotion] [bigint] IDENTITY(1,1) NOT NULL,
	[KeyPromotion] [nvarchar](18) NOT NULL,
	[SourceSystemCode] [varchar](10) NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[InsertDateTime] [datetime] NOT NULL,
 CONSTRAINT [PK_HubPromotion] PRIMARY KEY NONCLUSTERED 
	(
		[SKPromotion] ASC
	) NOT ENFORCED ,
 CONSTRAINT [UQ_HubPromotion_KeyPromotion] UNIQUE NONCLUSTERED 
	(
		[KeyPromotion] ASC
	) NOT ENFORCED 
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED INDEX
	(
		[KeyPromotion] ASC
	)
)