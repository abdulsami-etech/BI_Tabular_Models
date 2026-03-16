CREATE TABLE [SrcIDS].[tblPuRegionConfiguration]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[clin_id] [nvarchar](30) NULL,
	[country_code] [nvarchar](5) NULL,
	[region_code] [nvarchar](30) NULL,
	[name] [nvarchar](256) NULL,
	[value] [nvarchar](512) NULL,
	[created_by] [nvarchar](64) NULL,
	[create_date] [datetime2](7) NULL,
	[disable_date] [datetime2](7) NULL,
	[doctor_category] [nvarchar](12) NULL,
	[locale_id] [int] NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
)