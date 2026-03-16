CREATE TABLE [SrcWebStore].[spree_users]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[email] [nvarchar](256) NULL,
	[sign_in_count] [int] NOT NULL,
	[failed_attempts] [int] NOT NULL,
	[last_request_at] [datetime2](6) NULL,
	[current_sign_in_at] [datetime2](6) NULL,
	[last_sign_in_at] [datetime2](6) NULL,
	[current_sign_in_ip] [nvarchar](256) NULL,
	[last_sign_in_ip] [nvarchar](256) NULL,
	[login] [nvarchar](256) NULL,
	[ship_address_id] [int] NULL,
	[bill_address_id] [int] NULL,
	[created_at] [datetime2](6) NOT NULL,
	[updated_at] [datetime2](6) NOT NULL,
	[remember_created_at] [datetime2](6) NULL,
	[deleted_at] [datetime2](6) NULL,
	[confirmed_at] [datetime2](6) NULL,
	[confirmation_sent_at] [datetime2](6) NULL,
	[clinid] [nvarchar](256) NULL,
	[active] [bit] NULL,
	[ids_full_info] [nvarchar](max) NULL,
	[first_name] [nvarchar](256) NULL,
	[last_name] [nvarchar](256) NULL,
	[contact_id] [nvarchar](256) NULL,
	[salesforce_id] [nvarchar](256) NULL,
	[main_account_id] [nvarchar](256) NULL,
	[cases_12_months] [int] NULL,
	[teen_cases_12_months] [int] NULL,
	[is_dso] [bit] NULL,
	[is_invisalign_go] [bit] NULL,
	[is_itero] [bit] NULL,
	[is_territory_manager] [bit] NULL,
	[is_nume] [bit] NULL,
	[advantage_tier] [nvarchar](256) NULL,
	[practice_type] [nvarchar](256) NULL,
	[cert_level] [nvarchar](256) NULL,
	[line_of_business] [nvarchar](256) NULL,
	[teen_cases_on_date] [int] NULL,
	[certification_date] [datetime2](6) NULL,
	[segmentation] [nvarchar](256) NULL,
	[eligible_redemption] [bit] NULL,
	[segmentation_program] [nvarchar](256) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [id] ),
	CLUSTERED INDEX
	(
		[id] ASC
	)
)