CREATE TABLE [SrcIDS].[stp_data]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [uniqueidentifier] NOT NULL,
	[status] [nvarchar](10) NOT NULL,
	[so_number] [int] NOT NULL,
	[jde_patient_id] [int] NOT NULL,
	[mtp_id] [uniqueidentifier] NOT NULL,
	[clin_id] [nvarchar](50) NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[modified_date] [datetime2](7) NOT NULL,
	[plan_number] [int] NOT NULL,
	[qc_status] [smallint] NULL,
	[qc_completion_date] [datetime2](7) NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED INDEX
	(
		[mtp_id] ASC
	)
);


