CREATE TABLE [DW].[CaseStateStatistics] (
    [SKCaseStateStatistic] INT            NOT NULL,
    [OperationName]        NVARCHAR (250) NULL,
    [OperationType]        NVARCHAR (25)  NOT NULL,
    [Deviation1]           FLOAT (53)     NULL,
    [Deviation2]           FLOAT (53)     NULL,
    [Deviation3]           FLOAT (53)     NULL,
    [SourceSystem]         NVARCHAR (50)  NULL,
    [IsGlobalStatistic]    BIT            NULL,
    CONSTRAINT [CaseStateStatistics_Unique] UNIQUE NONCLUSTERED ([SKCaseStateStatistic] ASC, [OperationName] ASC, [OperationType] ASC, [SourceSystem] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SKCaseStateStatistic]));

