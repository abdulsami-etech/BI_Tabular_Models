CREATE TABLE [SrcEloomi].[course_categories]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[course_id] [int] NOT NULL,
	[category_id] [int] NOT NULL
)
WITH
(
	DISTRIBUTION = HASH ( [course_id] ),
	CLUSTERED COLUMNSTORE INDEX
)