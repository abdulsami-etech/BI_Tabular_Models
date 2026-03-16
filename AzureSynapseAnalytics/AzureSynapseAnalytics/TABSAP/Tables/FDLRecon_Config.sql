CREATE TABLE [TABSAP].[FDLRecon_Config] (
    [ConfigID]                  TINYINT       NOT NULL,
    [SQLTablename]              NVARCHAR (50) NOT NULL,
    [SAPTablename]              NVARCHAR (50) NOT NULL,
    [Columname]                 NVARCHAR (50) NOT NULL,
    [AggregateOperation]        NVARCHAR (50) NOT NULL,
    [GroupByColumn]             NVARCHAR (50) NOT NULL,
    [Filter_Condition_Column_1] NVARCHAR (50) NOT NULL,
    [Filter_Operator_1]         NVARCHAR (50) NOT NULL,
    [Filter_Value_1]            DATETIME2 (7) NOT NULL,
    [Filter_Condition_Column_2] NVARCHAR (50) NOT NULL,
    [Filter_Operator_2]         NVARCHAR (50) NOT NULL,
    [Filter_Value_2]            DATETIME2 (7) NOT NULL,
    [ObjectType]                NVARCHAR (50) NULL,
    [Full/Delta]                NVARCHAR (10) NULL,
    PRIMARY KEY NONCLUSTERED ([ConfigID] ASC) NOT ENFORCED,
    UNIQUE NONCLUSTERED ([SAPTablename] ASC) NOT ENFORCED,
    UNIQUE NONCLUSTERED ([SQLTablename] ASC) NOT ENFORCED
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

