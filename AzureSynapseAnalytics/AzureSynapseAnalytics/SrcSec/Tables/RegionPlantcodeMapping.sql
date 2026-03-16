CREATE TABLE [SrcSec].[RegionPlantcodeMapping]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[Region] [nvarchar](30) NULL,
	[PlantCode] [nvarchar](8) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)

