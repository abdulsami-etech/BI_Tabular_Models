CREATE TABLE [SrcMAT].[svc_Ticket_PartsTracking] (
    [LZBatchID]          INT             NOT NULL,
    [ADLSBatchID]        INT             NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)   NOT NULL,
    [Id]                 INT             NOT NULL,
    [RequestLinkId]      INT             NOT NULL,
    [TransitionSerialId] INT             NOT NULL,
    [IsArrived]          BIT             NOT NULL,
    [IsUsed]             BIT             NOT NULL,
    [IsDOA]              BIT             NOT NULL,
    [IsRMA]              BIT             NOT NULL,
    [RmaDetails]         NVARCHAR (255)  NULL,
    [Remarks]            NVARCHAR (255)  NULL,
    [ReplacedSerial]     NVARCHAR (256)  NULL,
    [Tracking]           NVARCHAR (100)  NULL,
    [ReportedIssue]      NVARCHAR (2000) NULL,
    [RootCause]          NVARCHAR (2000) NULL,
    [ReplacedId]         NVARCHAR (256)  NULL,
    [PartTypeId]         SMALLINT        NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

