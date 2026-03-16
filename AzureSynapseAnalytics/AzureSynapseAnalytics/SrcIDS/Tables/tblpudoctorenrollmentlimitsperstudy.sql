CREATE TABLE [SrcIDS].[tblpudoctorenrollmentlimitsperstudy]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[record_id] [int] NOT NULL,
	[master_user_id] [int] NOT NULL,
	[vip_study_id] [int] NOT NULL,
	[max_patients] [int] NULL,
    [_Region] [varchar] (32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [record_id] ),
	CLUSTERED INDEX
	(
		[record_id] ASC
	)
);


