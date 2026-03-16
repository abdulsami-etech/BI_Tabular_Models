CREATE TABLE [TABSAP].[FDLRecon_Difference] (
    [BatchID]        INT            NULL,
    [ConfigID]       TINYINT        NULL,
    [ConfigDateTime] DATETIME2 (7)  NULL,
    [SQLTablename]   NVARCHAR (50)  NULL,
    [SAPTablename]   NVARCHAR (50)  NULL,
    [DWCount]        INT            NULL,
    [SAPCount]       INT            NULL,
    [Period]         NVARCHAR (50)  NULL,
    [Difference]     NVARCHAR (50)  NULL,
    [TOT_DWCount]    INT            NULL,
    [TOT_SAPCount]   INT            NULL,
    [TOT_Difference] INT            NULL,
    [ExtractionType] NVARCHAR (30)  NULL,
    [Comments]       NVARCHAR (500) NULL,
    [ObjectType]     NVARCHAR (10)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

