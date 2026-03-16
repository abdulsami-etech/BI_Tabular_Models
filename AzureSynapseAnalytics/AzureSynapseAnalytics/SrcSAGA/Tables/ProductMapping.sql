CREATE TABLE [SrcSAGA].[ProductMapping]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[TreatmentOption] [varchar](128) NOT NULL,
	[DeliverableType] [varchar](128) NOT NULL,
	[Product] [varchar](64) NOT NULL,
	[AlignerType] [varchar](64) NOT NULL,
	[ProductCode] [varchar](8) NOT NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	HEAP
);


