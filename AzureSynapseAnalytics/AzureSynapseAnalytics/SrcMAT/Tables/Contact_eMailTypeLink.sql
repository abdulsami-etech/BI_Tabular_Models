CREATE TABLE [SrcMAT].[Contact_eMailTypeLink] (
    [LZBatchID]              INT            NOT NULL,
    [ADLSBatchID]            INT            NOT NULL,
    [ADLSTimestamp]          DATETIME2 (0)  NOT NULL,
    [ContactEmailTypeLinkID] INT            NOT NULL,
    [ContactID]              INT            NULL,
    [eMailTypeID]            INT            NULL,
    [eMailID]                INT            NULL,
    [DisplayName]            NVARCHAR (250) NULL,
    [IsPrimary]              INT            NULL,
    [RowStatusID]            INT            NULL,
    [DateCreated]            DATETIME       NULL,
    [DateUpdated]            DATETIME       NULL
)
WITH (CLUSTERED INDEX([ContactEmailTypeLinkID]), DISTRIBUTION = HASH([eMailID]));

