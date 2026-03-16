CREATE TABLE [TABSAP].[DW_DifferenceConfig] (
    [ConfigID]       TINYINT       NULL,
    [ConfigDateTime] DATETIME2 (7) NULL,
    [SQLTablename]   NVARCHAR (50) NOT NULL,
    [SAPTablename]   NVARCHAR (50) NOT NULL,
    [SQLResultCount] NVARCHAR (50) NOT NULL,
    [SAPResultCount] NVARCHAR (50) NOT NULL,
    [Difference]     NVARCHAR (50) NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

