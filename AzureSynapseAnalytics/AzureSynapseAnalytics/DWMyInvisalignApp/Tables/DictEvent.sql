CREATE TABLE [DWMyInvisalignApp].[DictEvent] (
    [SKEvent]         INT            NOT NULL,
    [EventName]       NVARCHAR (255) NOT NULL,
    [FeatureCategory] NVARCHAR (255) NOT NULL
)
WITH (CLUSTERED INDEX([SKEvent]), DISTRIBUTION = REPLICATE);

