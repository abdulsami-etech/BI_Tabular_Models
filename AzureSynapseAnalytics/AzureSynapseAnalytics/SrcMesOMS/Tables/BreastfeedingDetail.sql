CREATE TABLE [SrcMesOMS].[BreastfeedingDetail] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [breastfeedingDetailID] INT             NOT NULL,
    [breastfeedingMasterID] INT             NOT NULL,
    [takenHour]             VARCHAR (12)    NOT NULL,
    [totalMinutes]          DECIMAL (10, 2) NOT NULL,
    [creationDate]          DATETIME        NOT NULL,
    [modificationDate]      DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

