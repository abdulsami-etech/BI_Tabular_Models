CREATE TABLE [SrcWebStore].[spree_countries]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[id] [int] NOT NULL,
	[iso_name] [nvarchar](256) NULL,
	[iso] [nvarchar](256) NULL,
	[iso3] [nvarchar](256) NULL,
	[name] [nvarchar](256) NULL,
	[numcode] [int] NULL,
	[states_required] [bit] NULL,
	[updated_at] [datetime2](6) NOT NULL,
	[currency] [nvarchar](256) NULL,
	[default_locale] [nvarchar](512) NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
)