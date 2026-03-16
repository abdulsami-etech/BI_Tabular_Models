CREATE TABLE [SrcMesOMS].[StandardTime] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [standardTimeID]     INT           NOT NULL,
    [operationAliasID]   INT           NOT NULL,
    [areaID]             INT           NOT NULL,
    [regionID]           INT           NOT NULL,
    [familyItemNumberID] INT           NOT NULL,
    [siteID]             INT           NOT NULL,
    [creationDate]       DATETIME      NOT NULL,
    [createdBy]          INT           NOT NULL,
    [isActive]           BIT           NOT NULL,
    [isDeleted]          BIT           NOT NULL,
    [modificationDate]   DATETIME      NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

