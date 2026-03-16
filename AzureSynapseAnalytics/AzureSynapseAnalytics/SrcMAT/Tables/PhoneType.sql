CREATE TABLE [SrcMAT].[PhoneType] (
    [LZBatchID]                   INT           NOT NULL,
    [ADLSBatchID]                 INT           NOT NULL,
    [ADLSTimestamp]               DATETIME2 (0) NOT NULL,
    [PhoneTypeID]                 SMALLINT      NOT NULL,
    [PhoneTypeCode]               VARCHAR (10)  NOT NULL,
    [PhoneTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [RowStatusID]                 TINYINT       NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [CreatedByUserID]             INT           NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [UpdatedByUserID]             INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

