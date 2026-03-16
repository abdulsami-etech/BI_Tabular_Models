CREATE TABLE [DWSAP].[StandardProductHierarchie_Table] (
    [Level 1]   NVARCHAR (40) NULL,
    [Level 1 S] NVARCHAR (18) NULL,
    [Level 2]   NVARCHAR (40) NULL,
    [Level 2 S] NVARCHAR (18) NULL,
    [Level 3]   NVARCHAR (40) NULL,
    [Level 3 S] NVARCHAR (18) NULL,
    [Level 4]   NVARCHAR (40) NULL,
    [Level 4 S] NVARCHAR (18) NULL,
    [Level 5]   NVARCHAR (40) NULL,
    [Level 5 S] NVARCHAR (18) NULL,
    [Level 6]   NVARCHAR (40) NULL,
    [Level 6 S] NVARCHAR (18) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

