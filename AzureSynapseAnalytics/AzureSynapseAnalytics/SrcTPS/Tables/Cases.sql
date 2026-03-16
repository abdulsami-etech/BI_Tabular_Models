CREATE TABLE [SrcTPS].[Cases]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[case_id] [nvarchar](256) NOT NULL,
	[case_status] [int] NOT NULL,
	[case_type] [nvarchar](256) NOT NULL,
	[doctor_id] [nvarchar](256) NOT NULL,
	[treatment_type] [nvarchar](255) NULL,
	[lab_id] [bigint] NOT NULL,
	[updated_at] [datetime] NULL,
	[practice] [nvarchar](256) NULL,
	[shared_on] [datetime] NULL,
	[updated_by] [nvarchar](256) NOT NULL,
	[status_details] [int] NOT NULL,
	[order_id] [int] NULL,
	[jde_patient_id] [varchar](64) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [case_id] ),
	CLUSTERED INDEX
	(
		[case_id] ASC
	)
);