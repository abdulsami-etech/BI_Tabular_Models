CREATE TABLE [DWVirtualCare].[DictEvent] (
    [SKEvent]   INT            NOT NULL,
    [EventName] NVARCHAR (100) NOT NULL
)
WITH (CLUSTERED INDEX([SKEvent]), DISTRIBUTION = REPLICATE);

