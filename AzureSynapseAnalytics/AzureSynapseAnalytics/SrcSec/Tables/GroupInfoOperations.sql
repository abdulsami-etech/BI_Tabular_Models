CREATE TABLE [SrcSec].[GroupInfoOperations]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[GroupName] [nvarchar](100) NULL,
	[Region] [nvarchar](30) NULL,
	[Dataset] [nvarchar](20) NULL,
	[PlantType] [nvarchar](20) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	HEAP
)
