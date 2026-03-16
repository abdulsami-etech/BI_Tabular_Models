CREATE TABLE [DWTOPS].[HubCompleteReason] (
    [SKCompleteReason]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyCompleteReason] VARCHAR (64) NOT NULL,
    [SourceSystemCode]  VARCHAR (10) NOT NULL,
    [DWBatchID]         INT          NOT NULL,
    [InsertDateTime]    DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyCompleteReason]), DISTRIBUTION = REPLICATE);

