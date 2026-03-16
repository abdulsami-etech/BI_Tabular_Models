CREATE TABLE [SrcMAT].[eMail] (
    [LZBatchID]           INT            NOT NULL,
    [ADLSBatchID]         INT            NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)  NOT NULL,
    [eMailID]             INT            NOT NULL,
    [eMailAddress]        VARCHAR (250)  NOT NULL,
    [eMailAddressUnicode] NVARCHAR (500) NOT NULL,
    [NumberOfReferences]  INT            NOT NULL,
    [DoNotEMail]          BIT            NOT NULL,
    [RowStatusID]         TINYINT        NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [CreatedByUserID]     INT            NOT NULL,
    [DateUpdated]         DATETIME       NULL,
    [UpdatedByUserID]     INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

