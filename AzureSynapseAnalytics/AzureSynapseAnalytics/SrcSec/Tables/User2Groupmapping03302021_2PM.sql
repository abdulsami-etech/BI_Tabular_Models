CREATE TABLE [SrcSec].[User2Groupmapping03302021_2PM] (
    [LZBatchID]      INT           NOT NULL,
    [ADLSBatchID]    INT           NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0) NOT NULL,
    [UserName]       NVARCHAR (60) NOT NULL,
    [Email]          NVARCHAR (60) NULL,
    [GroupName]      NVARCHAR (60) NULL,
    [ChildGroupName] NVARCHAR (60) NULL,
    [Date]           NVARCHAR (10) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

