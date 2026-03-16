CREATE TABLE [DWMyInvisalignApp].[DictEventRule] (
    [SKEventRule] INT            NOT NULL,
    [SKEvent]     INT            NOT NULL,
    [SourceTable] NVARCHAR (50)  NULL,
    [SourceQuery] NVARCHAR (250) NULL
)
WITH (CLUSTERED INDEX([SKEventRule]), DISTRIBUTION = REPLICATE);

