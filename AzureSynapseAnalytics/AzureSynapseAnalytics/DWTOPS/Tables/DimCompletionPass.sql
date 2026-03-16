CREATE TABLE [DWTOPS].[DimCompletionPass] (
    [SKCompletionPass]  INT          NOT NULL,
    [KeyCompletionPass] VARCHAR (50) NOT NULL
)
WITH (CLUSTERED INDEX([SKCompletionPass]), DISTRIBUTION = REPLICATE);

