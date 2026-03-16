CREATE TABLE [SrcIDS].[tblPuDiscountProgram]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[program_id] [int] NOT NULL,
	[program_type] [smallint] NOT NULL,
	[program_name] [nvarchar](100) NULL,
	[description] [nvarchar](100) NULL,
	[doctor_category] [smallint] NOT NULL,
	[products] [nvarchar](255) NOT NULL,
	[program_code] [nvarchar](100) NOT NULL,
	[region_code] [nvarchar](50) NULL,
	[country_code] [nvarchar](50) NULL,
	[clin_id] [nvarchar](50) NULL,
	[start_date] [datetime2](7) NULL,
	[end_date] [datetime2](7) NULL,
	[disabled_at] [datetime2](7) NULL,
	[modified_at] [datetime2](7) NULL,
	[modified_by] [nvarchar](50) NOT NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [program_id] ),
	CLUSTERED INDEX
	(
		[program_id] ASC
	)
)