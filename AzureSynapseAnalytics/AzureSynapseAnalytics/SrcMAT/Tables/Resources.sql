CREATE TABLE [SrcMAT].[Resources] (
    [LZBatchID]                INT             NOT NULL,
    [ADLSBatchID]              INT             NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)   NOT NULL,
    [ResourceID]               INT             NOT NULL,
    [ResourceName]             NVARCHAR (100)  NULL,
    [ResourcePartnerID]        INT             NULL,
    [ResourceContactID]        INT             NULL,
    [ResourceSerialIdentifier] NVARCHAR (50)   NULL,
    [ResourceGUID]             NVARCHAR (4000) NULL,
    [MachineUniqueIdentifier]  VARCHAR (256)   NOT NULL,
    [RowStatusID]              TINYINT         NOT NULL,
    [DateCreated]              DATETIME        NOT NULL,
    [CreatedByUserID]          INT             NOT NULL,
    [DateUpdated]              DATETIME        NOT NULL,
    [UpdatedByUserID]          INT             NOT NULL,
    [InvalidateDate]           DATETIME        NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

