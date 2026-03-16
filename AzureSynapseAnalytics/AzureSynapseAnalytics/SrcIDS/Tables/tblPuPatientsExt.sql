CREATE TABLE [SrcIDS].[tblPuPatientsExt]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[vip_patient_id] [int] NOT NULL,
	[office_id] [bigint] NULL,
	[chief_concern] [varchar](100) NULL,
	[other_concern] [varchar](256) NULL,
	[notes] [nvarchar](300) NULL,
	[forms_migration_status] [smallint] NULL,
	[other_concern_internal] [varchar](256) NULL,
	[records_type] [smallint] NULL,
	[order_number] [varchar](50) NULL,
	[vendor] [smallint] NULL,
	[modified_at] [datetime2] (7) NULL,
	[labels] [varchar](100) NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [vip_patient_id] ),
	CLUSTERED COLUMNSTORE INDEX
);


