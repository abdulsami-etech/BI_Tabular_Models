CREATE TABLE [SrcIDS].[polaris_data_cleansing]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[clinid] [varchar](50) NOT NULL,
	[form_submitted] [bit] NULL,
	[display_counter] [int] NULL,
	[created_at] [datetime2](7) NULL,
	[modified_at] [datetime2](7) NULL,
    [_Region]           VARCHAR (32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [clinid] ),
	CLUSTERED INDEX
	(
		[clinid] ASC
	)
)



