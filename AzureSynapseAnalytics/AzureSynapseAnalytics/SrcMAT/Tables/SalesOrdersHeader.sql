CREATE TABLE [SrcMAT].[SalesOrdersHeader] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [SalesOrderHeaderID]   INT           NOT NULL,
    [SalesOrderHeaderCode] VARCHAR (12)  NULL,
    [InitiatorPartnerID]   INT           NULL,
    [InitiatorContactID]   INT           NULL,
    [RowStatusID]          TINYINT       NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [CreatedByUserID]      INT           NOT NULL,
    [DateUpdated]          DATETIME      NULL,
    [UpdatedByUserID]      INT           NOT NULL,
    [Notes]                VARCHAR (MAX) NULL
)
WITH (CLUSTERED INDEX([SalesOrderHeaderID]), DISTRIBUTION = HASH([SalesOrderHeaderID]));

