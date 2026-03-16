CREATE TABLE [SrcSAPFile].[DeliverableType] (
    [LZBatchID]                    INT           NOT NULL,
    [ADLSBatchID]                  INT           NOT NULL,
    [ADLSTimestamp]                DATETIME2 (0) NOT NULL,
    [DeliverableTypeKey]           INT           NOT NULL,
    [SAPDeliverableType]           NVARCHAR (30) NULL,
    [TreatmentCategory]            NVARCHAR (30) NULL,
    [DeliverableTypeName]          NVARCHAR (30) NULL,
    [SortOrder]                    INT           NULL,
    [SAPOrderType]                 NVARCHAR (30) NULL,
    [IncludeforNASalesRevenue]     NVARCHAR (3)  NULL,
    [IncludeforNATotalCaseCounts]  NVARCHAR (3)  NULL,
    [IncludeForNADetailCaseCounts] NVARCHAR (3)  NULL,
    [ProductHierarchy]             NVARCHAR (50) NULL,
    [AdditionalAlignerIncluded]    NVARCHAR (3)  NULL,
    [MaterialNumber]               NVARCHAR (20) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

