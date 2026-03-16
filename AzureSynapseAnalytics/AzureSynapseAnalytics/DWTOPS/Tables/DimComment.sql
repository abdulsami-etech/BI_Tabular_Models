CREATE TABLE [DWTOPS].[DimComment] (
    [SKComment]     INT            NOT NULL,
    [ADLSBatchID]   INT            NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)  NOT NULL,
    [LZBatchID]     INT            NOT NULL,
    [DWBatchID]     INT            NOT NULL,
    [DWHash]        CHAR (40)      NOT NULL,
    [KeyComment]    NVARCHAR (255) NOT NULL
)
WITH (CLUSTERED INDEX([SKComment]), DISTRIBUTION = HASH([SKComment]));

