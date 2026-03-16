CREATE TABLE [SrcMAT].[Case_CaseTypes] (
    [LZBatchID]                  INT           NOT NULL,
    [ADLSBatchID]                INT           NOT NULL,
    [ADLSTimestamp]              DATETIME2 (0) NOT NULL,
    [CaseTypeID]                 SMALLINT      NOT NULL,
    [CaseTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [CaseTypeGroupID]            INT           NULL,
    [DisplayOrder]               INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

