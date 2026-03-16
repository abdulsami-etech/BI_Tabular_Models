CREATE TABLE [SrcMesOMS].[DownTimeReported] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [downTimeReportedID]    INT             NOT NULL,
    [technicianID]          INT             NOT NULL,
    [startTime]             DATETIME        NOT NULL,
    [endTime]               DATETIME        NOT NULL,
    [areaID]                INT             NOT NULL,
    [groupID]               INT             NULL,
    [operationID]           INT             NOT NULL,
    [downTimeCategoryID]    INT             NOT NULL,
    [downTimeSubCategoryID] INT             NOT NULL,
    [downTimeTopicID]       INT             NOT NULL,
    [cellID]                INT             NOT NULL,
    [regionID]              INT             NOT NULL,
    [scheduleID]            INT             NOT NULL,
    [rttHeadID]             INT             NULL,
    [modifiedByID]          INT             NULL,
    [createdByID]           INT             NULL,
    [totalDownTime]         DECIMAL (10, 2) NOT NULL,
    [downTimeDate]          DATETIME        NOT NULL,
    [creationDate]          DATETIME        NOT NULL,
    [modificationDate]      DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

