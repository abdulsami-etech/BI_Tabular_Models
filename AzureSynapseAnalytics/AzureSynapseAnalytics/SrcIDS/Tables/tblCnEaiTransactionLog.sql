CREATE TABLE [SrcIDS].[tblCnEaiTransactionLog]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[transaction_id] [int] NOT NULL,
	[xml] [nvarchar](max) NULL,
	[queue_name] [nvarchar](256) NULL,
	[external_id] [int] NOT NULL,
	[status_id] [int] NULL,
	[error_message] [nvarchar](max) NULL,
	[create_datetime] [datetime2](7) NOT NULL,
	[request_datetime] [datetime2](7) NULL,
	[status_update_datetime] [datetime2](7) NULL,
	[disable_datetime] [datetime2](7) NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [transaction_id] ),
	CLUSTERED INDEX
	(
		[transaction_id] ASC
	)
);


