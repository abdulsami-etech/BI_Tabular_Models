CREATE TABLE [SrcSplunk].[CCCloud_MiscRecalc]
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
	[_data] [nvarchar](4000) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)