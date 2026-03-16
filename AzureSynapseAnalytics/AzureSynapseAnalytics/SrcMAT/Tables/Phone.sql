CREATE TABLE [SrcMAT].[Phone] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [PhoneID]            INT           NOT NULL,
    [LocaleID]           SMALLINT      NOT NULL,
    [PhoneNumber]        VARCHAR (50)  NOT NULL,
    [PhoneCleanNumber]   VARCHAR (50)  NULL,
    [NumberOfReferences] INT           NOT NULL,
    [DoNotCallOrFax]     BIT           NOT NULL,
    [RowStatusID]        TINYINT       NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [CreatedByUserID]    INT           NOT NULL,
    [DateUpdated]        DATETIME      NULL,
    [UpdatedByUserID]    INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

