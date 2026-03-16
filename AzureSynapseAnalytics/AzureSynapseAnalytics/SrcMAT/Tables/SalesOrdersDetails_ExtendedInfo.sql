CREATE TABLE [SrcMAT].[SalesOrdersDetails_ExtendedInfo] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [SalesOrderDetailsID]   INT             NOT NULL,
    [FinancialApproved]     BIT             NOT NULL,
    [FinancialApprovedDate] DATETIME        NULL,
    [OrderRefNumber]        NVARCHAR (50)   NULL,
    [Cost]                  DECIMAL (18, 3) NOT NULL,
    [Currency]              NVARCHAR (10)   NULL,
    [Discount]              DECIMAL (18, 3) NOT NULL,
    [RevRec]                NVARCHAR (50)   NULL,
    [RevRecDate]            DATETIME        NULL,
    [LinkedTicketID]        INT             NULL,
    [RowStatusID]           TINYINT         NOT NULL,
    [DateCreated]           DATETIME        NOT NULL,
    [CreatedByUserID]       INT             NOT NULL,
    [DateUpdated]           DATETIME        NULL,
    [UpdatedByUserID]       INT             NOT NULL,
    [TransitionHeaderID]    INT             NULL,
    [ScannerModelID]        INT             NOT NULL,
    [ScannerTypeID]         INT             NOT NULL,
    [TrainingWaived]        BIT             NOT NULL
)
WITH (CLUSTERED INDEX([SalesOrderDetailsID]), DISTRIBUTION = ROUND_ROBIN);

