CREATE TABLE [DWTOPS].[DimUser] (
    [SKUser]          INT           NOT NULL,
    [ADLSBatchID]     INT           NOT NULL,
    [ADLSTimestamp]   DATETIME2 (0) NOT NULL,
    [LZBatchID]       INT           NOT NULL,
    [DWBatchID]       INT           NOT NULL,
    [DWHash]          CHAR (40)     NOT NULL,
    [KeyUser]         VARCHAR (64)  NOT NULL,
    [UserKey]         BIGINT        NOT NULL,
    [FirstName]       VARCHAR (64)  NULL,
    [LastName]        VARCHAR (64)  NULL,
    [FullName]        VARCHAR (128) NULL,
    [UserDescription] VARCHAR (255) NULL,
    [UserCategory]    VARCHAR (50)  NULL,
    [UserShift]       VARCHAR (80)  NULL
)
WITH (CLUSTERED INDEX([SKUser]), DISTRIBUTION = REPLICATE);

