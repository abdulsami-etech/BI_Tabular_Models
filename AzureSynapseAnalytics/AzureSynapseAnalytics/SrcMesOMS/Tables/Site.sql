CREATE TABLE [SrcMesOMS].[Site] (
    [LZBatchID]     INT             NOT NULL,
    [ADLSBatchID]   INT             NOT NULL,
    [ADLSTimestamp] DATETIME2 (0)   NOT NULL,
    [siteID]        INT             NOT NULL,
    [siteName]      VARCHAR (50)    NOT NULL,
    [isActive]      BIT             NOT NULL,
    [timeOffset]    DECIMAL (10, 2) NOT NULL,
    [timezoneName]  VARCHAR (50)    NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

