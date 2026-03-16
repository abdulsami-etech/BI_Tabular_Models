CREATE TABLE [SrcSplunk].[CCCloud_CaseInfo]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[trace] [nvarchar](100) NOT NULL,
	[action] [nvarchar](250) NOT NULL,
	[ts] [varchar](32) NOT NULL,
	[data_md5] [char](32) NOT NULL,
	[_count] [int] NOT NULL,
	[splunk_time] [datetimeoffset](7) NULL,
	[patient_md5] [char](32) NULL,
	[patient_sha256] [char](64) NULL,
	[canShareTreatmentPlan] [bit] NULL,
	[isSmileViewProEnabled] [bit] NULL,
	[caseId] [nvarchar](36) NULL,
	[clinicianId] [nvarchar](64) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [trace] ),
	CLUSTERED COLUMNSTORE INDEX
)