CREATE TABLE [SrcMAT].[AddressType] (
    [LZBatchID]                     INT           NOT NULL,
    [ADLSBatchID]                   INT           NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0) NOT NULL,
    [AddressTypeID]                 SMALLINT      NOT NULL,
    [AddressTypeCode]               VARCHAR (50)  NOT NULL,
    [AddressTypeGenericDescription] VARCHAR (50)  NOT NULL,
    [RowStatusID]                   TINYINT       NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [CreatedByUserID]               INT           NOT NULL,
    [DateUpdated]                   DATETIME      NOT NULL,
    [UpdatedByUserID]               INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

