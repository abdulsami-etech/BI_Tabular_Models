CREATE TABLE [SrcMesOMS].[BreastfeedingMaster] (
    [LZBatchID]             INT           NOT NULL,
    [ADLSBatchID]           INT           NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0) NOT NULL,
    [breastfeedingMasterID] INT           NOT NULL,
    [technicianID]          INT           NOT NULL,
    [createdBy]             INT           NOT NULL,
    [createdDate]           DATETIME      NOT NULL,
    [isActive]              BIT           NOT NULL,
    [startDate]             DATETIME      NOT NULL,
    [endDate]               DATETIME      NOT NULL,
    [isDeleted]             BIT           NOT NULL,
    [modificationDate]      DATETIME      NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

