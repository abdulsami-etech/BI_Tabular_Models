CREATE TABLE [SrcMesOMS].[ProductionDetail] (
    [LZBatchID]            INT             NOT NULL,
    [ADLSBatchID]          INT             NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0)   NOT NULL,
    [productionDetailID]   BIGINT          NOT NULL,
    [productionMasterID]   BIGINT          NOT NULL,
    [operationID]          INT             NOT NULL,
    [numberOfNewCases]     INT             NOT NULL,
    [numberOfReCC]         INT             NOT NULL,
    [totalCases]           INT             NOT NULL,
    [equivalentTotalCases] DECIMAL (18, 2) NOT NULL,
    [isOvertime]           BIT             NOT NULL,
    [reportID]             INT             NOT NULL,
    [standardTime]         DECIMAL (18, 2) NULL,
    [effectiveTime]        DECIMAL (18, 2) NOT NULL,
    [orderCategoryID]      INT             NULL,
    [standardTimeID]       INT             NULL,
    [familyItemNumberID]   INT             NULL,
    [orderRegionID]        INT             NULL,
    [IOS]                  INT             NULL,
    [PVS]                  INT             NULL,
    [creationDate]         DATETIME        NOT NULL,
    [modificationDate]     DATETIME        NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([productionMasterID]));

