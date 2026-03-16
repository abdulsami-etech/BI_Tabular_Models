CREATE TABLE [SrcEloomi].[users]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[first_name] [nvarchar](100) NULL,
	[last_name] [nvarchar](100) NULL,
	[employee_id] [nvarchar](100) NULL,
	[function] [nvarchar](100) NULL,
	[generic_role] [nvarchar](100) NULL,
	[title] [nvarchar](100) NULL,
	[gender] [nvarchar](20) NULL,
	[email] [nvarchar](100) NULL,
	[country] [nvarchar](50) NULL,
	[location] [nvarchar](100) NULL,
	[activated] [nvarchar](100) NULL,
	[activated_at] [datetime2](7) NULL,
	[deactivated_at] [datetime2](7) NULL,
	[start_of_employment_at] [datetime2](7) NULL,
	[end_of_employment_at] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
)




