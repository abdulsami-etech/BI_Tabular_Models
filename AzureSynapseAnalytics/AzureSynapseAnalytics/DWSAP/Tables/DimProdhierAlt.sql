CREATE TABLE [DWSAP].[DimProdhierAlt] (
    [Level 1]        NVARCHAR (255) NULL,
    [Level 2]        NVARCHAR (255) NULL,
    [Level 3]        NVARCHAR (255) NULL,
    [Level 4]        NVARCHAR (255) NULL,
    [Level 5]        NVARCHAR (255) NULL,
    [Level 6]        NVARCHAR (255) NULL,
    [Level 7]        NVARCHAR (255) NULL,
    [Level 8]        NVARCHAR (255) NULL,
    [PRODH]          NVARCHAR (255) NULL,
    [PROD HIERARCHY] NVARCHAR (255) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

