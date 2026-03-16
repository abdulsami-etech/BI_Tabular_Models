CREATE TABLE [DWAppLog].[DictEvent] (
    [SKEvent]          INT            IDENTITY (1, 1) NOT NULL,
    [FullName]         NVARCHAR (255) NOT NULL,
    [SourceSystemCode] VARCHAR (10)   NOT NULL,
    [H_Level1]         NVARCHAR (50)  NOT NULL,
    [H_Level2]         NVARCHAR (50)  NOT NULL,
    [H_Level3]         NVARCHAR (50)  NOT NULL,
    [H_Level4]         NVARCHAR (50)  NOT NULL
)
WITH (CLUSTERED INDEX([SKEvent]), DISTRIBUTION = REPLICATE);

