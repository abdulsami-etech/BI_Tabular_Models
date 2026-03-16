CREATE TABLE [DWSAP].[StandardProfitCenterHierarchy_Table] (
    [Level 1]        NVARCHAR (40) NULL,
    [Level 2]         NVARCHAR (40) NULL,
    [SequenceNumber2] INT           NULL,
    [Level 3]         NVARCHAR (40) NULL,
    [SequenceNumber3] INT           NULL,
    [Level 4]         NVARCHAR (40) NULL,
    [SequenceNumber4] INT           NULL,
    [Level 5]         NVARCHAR (40) NULL,
    [SequenceNumber5] INT           NULL,
    [Level 6]         NVARCHAR (40) NULL,
    [SequenceNumber6] INT           NULL,
    [Level 7]         NVARCHAR (40) NULL,
    [SequenceNumber7] INT           NULL,
    [Level 8]         NVARCHAR (10) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

