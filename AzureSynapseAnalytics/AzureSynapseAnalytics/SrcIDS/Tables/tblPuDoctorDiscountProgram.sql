CREATE TABLE [SrcIDS].[tblPuDoctorDiscountProgram]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[doctor_discount_id] [int] NOT NULL,
	[program_id] [int] NOT NULL,
	[clin_id] [nvarchar](30) NOT NULL,
	[discount_counter] [int] NOT NULL,
	[start_date] [datetime2](7) NOT NULL,
	[end_date] [datetime2](7) NOT NULL,
	[modified_at] [datetime2](7) NOT NULL,
	[modified_by] [nvarchar](50) NOT NULL,
	[grant_counter] [int] NOT NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [doctor_discount_id] ),
	CLUSTERED INDEX
	(
		[doctor_discount_id] ASC
	)
)