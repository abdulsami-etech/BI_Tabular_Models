CREATE TABLE [SrcIDS].[tblpuclinstudyfeatures]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[clinstudy_id] [int] NOT NULL,
	[created_by] [nvarchar](64) NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[disable_date] [datetime2](7) NULL,
	[configuration] [nvarchar](64) NULL,
	[eligible_products] [nvarchar](64) NULL,
    [_Region] [varchar] (32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
);


