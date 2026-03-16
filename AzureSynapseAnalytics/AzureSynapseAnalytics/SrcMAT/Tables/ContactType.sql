CREATE TABLE [SrcMAT].[ContactType] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [ContactTypeID]                 INT           NOT NULL,
    [ContactTypeGroupID]            INT           NOT NULL,
    [ContactTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [DisplayOrder]                  INT           NULL,
    [RowStatusID]                   TINYINT       NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [CreatedByUserID]               INT           NOT NULL,
    [DateUpdated]                   DATETIME      NOT NULL,
    [UpdatedByUserID]               INT           NOT NULL,
    [Type]                          INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

