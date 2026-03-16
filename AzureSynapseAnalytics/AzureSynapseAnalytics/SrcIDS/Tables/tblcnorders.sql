CREATE TABLE [SrcIDS].[tblcnorders]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[vip_order_id] [int] NOT NULL,
	[billing_id] [bigint] NULL,
	[shipping_id] [bigint] NULL,
	[treatment_location] [bigint] NULL,
	[item_num] [int] NULL,
	[document_type] [varchar](50) NULL,
	[initial_order_type] [int] NULL,
	[version_id] [varchar](50) NULL,
	[business_unit] [varchar](10) NULL,
	[quantity] [int] NULL,
	[unit_of_measure] [varchar](50) NULL,
	[upper_start] [varchar](50) NULL,
	[upper_end] [varchar](50) NULL,
	[lower_start] [varchar](50) NULL,
	[lower_end] [varchar](50) NULL,
	[tps_number] [varchar](50) NULL,
	[promotion_code] [varchar](50) NULL,
	[key_company] [varchar](50) NULL,
	[disabled] [datetime2](7) NULL,
	[create_date] [datetime2](7) NULL,
	[create_user_id] [nvarchar](255) NULL,
	[assessment_type] [int] NULL,
	[priority] [varchar](1) NULL,
	[auto_accept] [bit] NULL,
	[auto_accept_reset_datetime] [datetime2](7) NULL,
	[shipping_type] [smallint] NULL,
	[modified_date] [datetime2](7) NULL,
	[soldto_id] [int] NULL,
    [_Region] [varchar](32)   NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [vip_order_id] ),
	CLUSTERED COLUMNSTORE INDEX
);


