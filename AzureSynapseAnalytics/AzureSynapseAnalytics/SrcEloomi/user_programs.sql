CREATE TABLE [SrcEloomi].[user_programs]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[program_id] [bigint] NOT NULL,
	[user_id] [bigint] NOT NULL,
	[progress] [decimal](38, 12) NULL,
	[assigned_at] [datetime2](7) NULL,
	[completed_at] [datetime2](7) NULL,
	[time_spent] [datetime2](7) NULL,
	[deadline] [datetime2](7) NULL
)
WITH
(
	DISTRIBUTION = HASH ( [program_id] ),
	CLUSTERED COLUMNSTORE INDEX
)
