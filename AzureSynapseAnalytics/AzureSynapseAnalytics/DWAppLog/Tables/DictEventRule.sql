CREATE TABLE [DWAppLog].[DictEventRule] (
    [SKEventRule]      INT            IDENTITY (1, 1) NOT NULL,
    [SKEvent]          INT            NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NULL,
    [SourceTable]      NVARCHAR (50)  NULL,
    [SourceQuery]      NVARCHAR (250) NULL
)
WITH (CLUSTERED INDEX([SKEventRule]), DISTRIBUTION = REPLICATE);

