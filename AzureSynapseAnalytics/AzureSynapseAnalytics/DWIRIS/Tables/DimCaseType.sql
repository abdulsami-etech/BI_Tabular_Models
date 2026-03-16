CREATE TABLE [DWIRIS].[DimCaseType] (
    [SKCaseType]                 INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [LZBatchID]                  INT           NOT NULL,
    [DWBatchID]                  INT           NOT NULL,
    [DWHash]                     CHAR (40)     NOT NULL,
    [KeyCaseType]                CHAR (40)     NOT NULL,
    [SourceSystem]               CHAR (40)     NOT NULL,
    [CaseTypeGenericDescription] NVARCHAR (50) NOT NULL,
    [CaseTypeCategory]           NVARCHAR (50) NOT NULL,
    [CaseTypeGroupID]            INT           NULL,
    [CaseTypeDisplayOrder]       INT           NOT NULL
)
WITH (CLUSTERED INDEX([SKCaseType]), DISTRIBUTION = REPLICATE);

