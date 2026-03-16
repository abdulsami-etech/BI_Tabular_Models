CREATE TABLE [SrcMAT].[TransitionDetails] (
    [LZBatchID]               INT             NOT NULL,
    [ADLSBatchID]             INT             NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)   NOT NULL,
    [TransitionDetailsID]     INT             NOT NULL,
    [TransitionHeaderID]      INT             NULL,
    [ItemID]                  INT             NULL,
    [Quantity]                DECIMAL (10, 2) NULL,
    [SalesOrderDetailsID]     INT             NULL,
    [ExternalReference]       NVARCHAR (50)   NULL,
    [SourceBusinessPartnerID] INT             NULL,
    [Notes]                   NVARCHAR (4000) NULL,
    [RowStatusID]             INT             NULL,
    [DateCreated]             DATETIME        NULL,
    [DateUpdated]             DATETIME        NULL
)
WITH (CLUSTERED INDEX([TransitionDetailsID]), DISTRIBUTION = HASH([TransitionHeaderID]));

