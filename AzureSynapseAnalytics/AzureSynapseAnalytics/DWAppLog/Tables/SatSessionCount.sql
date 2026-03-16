CREATE TABLE [DWAppLog].[SatSessionCount] (
    [SKSession]       INT       NOT NULL,
    [DWBatchID]       INT       NOT NULL,
    [DWHash]          CHAR (40) NOT NULL,
    [_3DControls]     INT       NOT NULL,
    [CCMod]           INT       NOT NULL,
    [CCA]             INT       NOT NULL,
    [IFVModification] INT       NOT NULL,
    [IFVReview]       INT       NOT NULL,
    [DurationSecond]  INT       NOT NULL
)
WITH (    CLUSTERED COLUMNSTORE INDEX,
          DISTRIBUTION = HASH(SKSession)
    );

