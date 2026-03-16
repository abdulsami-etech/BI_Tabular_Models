CREATE TABLE [SrcMAT].[Activity] (
    [LZBatchID]         INT             NOT NULL,
    [ADLSBatchID]       INT             NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)   NOT NULL,
    [ActivityID]        INT             NOT NULL,
    [ActivityTypeID]    SMALLINT        NOT NULL,
    [ActivitySubTypeID] SMALLINT        NOT NULL,
    [ActivityNotes]     NVARCHAR (2000) NOT NULL,
    [ActivitySpokeWith] NVARCHAR (200)  NOT NULL,
    [RowStatusID]       TINYINT         NOT NULL,
    [DateCreated]       DATETIME        NOT NULL,
    [CreatedByUserID]   INT             NOT NULL,
    [DateUpdated]       DATETIME        NOT NULL,
    [UpdatedByUserID]   INT             NOT NULL,
    [ActivityState]     INT             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([ActivityID]));

