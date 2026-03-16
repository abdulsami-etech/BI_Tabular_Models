CREATE TABLE [SrcEloomi].[user_courses]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[course_id] [int] NOT NULL,
	[user_id] [int] NULL,
	[score] [decimal](38, 12) NULL,
	[progress] [decimal](38, 12) NULL,
	[attempts] [nvarchar](100) NULL,
	[assigned_at] [datetime2](7) NULL,
	[started_at] [datetime2](7) NULL,
	[completed_at] [datetime2](7) NULL,
	[time_spent] [datetime2](7) NULL,
	[deadline] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [course_id] ),
	CLUSTERED COLUMNSTORE INDEX
)
