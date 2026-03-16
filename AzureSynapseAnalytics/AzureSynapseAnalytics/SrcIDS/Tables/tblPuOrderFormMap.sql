CREATE TABLE [SrcIDS].[tblPuOrderFormMap]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[rx_form_id] [int] NOT NULL,
	[vip_order_id] [int] NOT NULL,
    [_Region] [varchar](32) NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [rx_form_id] ),
	CLUSTERED INDEX
	(
		[rx_form_id] ASC
	)
)