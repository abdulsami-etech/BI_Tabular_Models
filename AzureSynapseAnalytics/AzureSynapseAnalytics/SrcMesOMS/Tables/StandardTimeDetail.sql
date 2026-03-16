CREATE TABLE [SrcMesOMS].[StandardTimeDetail] (
    [LZBatchID]        INT             NOT NULL,
    [ADLSBatchID]      INT             NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)   NOT NULL,
    [standardTimeID]   INT             NOT NULL,
    [orderCategoryID]  INT             NOT NULL,
    [stdNewCase]       DECIMAL (10, 3) NULL,
    [stdCCMods]        DECIMAL (10, 3) NULL,
    [stdPvs]           DECIMAL (10, 3) NULL,
    [stdIos]           DECIMAL (10, 3) NULL,
    [creationDate]     DATETIME        NOT NULL,
    [modificationDate] DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

