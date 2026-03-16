CREATE TABLE [SrcMesOMS].[Overtime] (
    [LZBatchID]        INT             NOT NULL,
    [ADLSBatchID]      INT             NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0)   NOT NULL,
    [overTimeID]       INT             NOT NULL,
    [technicianID]     INT             NOT NULL,
    [startDate]        DATETIME        NOT NULL,
    [endDate]          DATETIME        NOT NULL,
    [operationID]      INT             NOT NULL,
    [areaID]           INT             NOT NULL,
    [groupID]          INT             NULL,
    [rttHeadID]        INT             NOT NULL,
    [modifiedByID]     INT             NULL,
    [createdByID]      INT             NULL,
    [breakTimeTypeID]  INT             NULL,
    [regionID]         INT             NULL,
    [cellID]           INT             NULL,
    [scheduleID]       INT             NULL,
    [overTimeDate]     DATETIME        NOT NULL,
    [totalOvertime]    DECIMAL (10, 2) NOT NULL,
    [creationDate]     DATETIME        NOT NULL,
    [modificationDate] DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

