CREATE TABLE [SrcIDS].[tblcnclinstudyenrolldoc]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[clinstudyenrolldoc_id] [int] NOT NULL,
	[master_user_id] [int] NOT NULL,
	[clinstudy_id] [int] NOT NULL,
	[user_name] [nvarchar](64) NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[disabled_date] [datetime2](7) NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [clinstudyenrolldoc_id] ),
	CLUSTERED INDEX
	(
		[clinstudyenrolldoc_id] ASC
	)
);


