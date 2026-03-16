CREATE TABLE [SrcMesOMS].[ProductionMaster] (
    [LZBatchID]                        INT            NOT NULL,
    [ADLSBatchID]                      INT            NOT NULL,
    [ADLSTimestamp]                    DATETIME2 (0)  NOT NULL,
    [productionMasterID]               BIGINT         NOT NULL,
    [technicianID]                     INT            NOT NULL,
    [areaID]                           INT            NOT NULL,
    [principalOperationID]             INT            NOT NULL,
    [scheduleID]                       INT            NOT NULL,
    [rttHeadID]                        INT            NOT NULL,
    [groupID]                          INT            NULL,
    [cellID]                           INT            NOT NULL,
    [regionID]                         INT            NOT NULL,
    [dateProduction]                   DATETIME       NOT NULL,
    [totalHoursDownTime]               DECIMAL (8, 2) NOT NULL,
    [totalHoursVADownTime]             DECIMAL (8, 2) NULL,
    [efficiency]                       DECIMAL (8, 2) NULL,
    [expectedStandardTime]             DECIMAL (8, 3) NOT NULL,
    [expectedCasesPerHour]             DECIMAL (8, 2) NOT NULL,
    [principalOperationStandardTimeID] INT            NULL,
    [breastfeedingMasterID]            INT            NULL,
    [breakTimeMasterID]                INT            NULL,
    [siteID]                           INT            NOT NULL,
    [creationDate]                     DATETIME       NOT NULL,
    [modificationDate]                 DATETIME       NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([productionMasterID]));

