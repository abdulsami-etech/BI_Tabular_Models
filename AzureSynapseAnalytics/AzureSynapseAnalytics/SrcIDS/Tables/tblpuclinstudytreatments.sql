CREATE TABLE [SrcIDS].[tblpuclinstudytreatments]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[treatment_id] [int] NOT NULL,
	[vip_order_id] [int] NOT NULL,
	[clinstudy_id] [int] NOT NULL,
	[event_id] [int] NULL,
	[export_id] [int] NULL,
	[status] [smallint] NOT NULL,
	[create_date] [datetime2](7) NOT NULL,
	[starting_voi] [int] NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [treatment_id] ),
	CLUSTERED INDEX
	(
		[treatment_id] ASC
	)
);


