CREATE TABLE [SrcSplunk].[CCCloud_PowerTools]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[trace] [nvarchar](100) NOT NULL,
	[action] [nvarchar](250) NOT NULL,
	[ts] [datetimeoffset](7) NOT NULL,
	[_count] [int] NOT NULL,
	[splunk_time] [datetimeoffset](7) NULL,
	[appVersion] [nvarchar](50) NULL,
	[_data] [nvarchar](4000) NULL,
	[data_md5] [nvarchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)