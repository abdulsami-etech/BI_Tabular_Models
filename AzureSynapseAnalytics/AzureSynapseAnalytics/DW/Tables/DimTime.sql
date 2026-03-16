CREATE TABLE [DW].[DimTime] (
    [SKTime]       INT          NOT NULL,
    [KeyTime]      TIME (0)     NULL,
    [Time]         VARCHAR (8)  NOT NULL,
    [AmPm]         CHAR (2)     NULL,
    [MilitaryHour] CHAR (2)     NULL,
    [MilitaryTime] CHAR (8)     NULL,
    [MinuteOfHour] INT          NULL,
    [StandardHour] CHAR (2)     NULL,
    [StandardTime] CHAR (8)     NULL,
    [TimeOfDay]    VARCHAR (50) NULL
)
WITH (CLUSTERED INDEX([SKTime]), DISTRIBUTION = REPLICATE);


GO
CREATE NONCLUSTERED INDEX [IX_DimTime_KeyTime]
    ON [DW].[DimTime]([KeyTime] ASC);

