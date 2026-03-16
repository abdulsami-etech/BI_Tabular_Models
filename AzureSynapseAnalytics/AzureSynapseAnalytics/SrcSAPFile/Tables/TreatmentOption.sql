CREATE TABLE [SrcSAPFile].[TreatmentOption] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [TreatmentOptionKey]            INT           NOT NULL,
    [SAPTreatmentOption]            NVARCHAR (30) NULL,
    [TreatmentOption]               NVARCHAR (30) NULL,
    [SortOrder]                     INT           NULL,
    [ProductHierarchy]              NVARCHAR (50) NULL,
    [TreatmentOptionHighLevel]      NVARCHAR (50) NULL,
    [TreatmentOptionReportingLevel] NVARCHAR (50) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

