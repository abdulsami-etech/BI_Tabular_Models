CREATE TABLE [SrcIDS].[tblcnclinstudies]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[clinstudy_id] [int] NOT NULL,
	[details_page_url] [nvarchar](512) NOT NULL,
	[createdate] [datetime2](7) NOT NULL,
	[name_i18nid] [int] NULL,
	[psintervals] [nvarchar](1000) NOT NULL,
	[maxpatenroll] [int] NULL,
	[studyclosed_date] [datetime2](7) NULL,
	[studyname] [nvarchar](256) NULL,
	[rule_type] [smallint] NOT NULL,
	[enrollmentstartdate] [datetime2](7) NOT NULL,
	[enrollmentenddate] [datetime2](7) NOT NULL,
	[externalid] [nvarchar](256) NOT NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [clinstudy_id] ),
	CLUSTERED INDEX
	(
		[clinstudy_id] ASC
	)
);


