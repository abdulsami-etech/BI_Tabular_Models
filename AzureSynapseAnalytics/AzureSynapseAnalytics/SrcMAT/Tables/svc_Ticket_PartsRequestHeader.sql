CREATE TABLE [SrcMAT].[svc_Ticket_PartsRequestHeader] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [Id]                    INT            NOT NULL,
    [TicketID]              INT            NOT NULL,
    [ServiceProvider]       NVARCHAR (255) NOT NULL,
    [ScheduledShipmentDate] DATETIME       NULL,
    [ScheduledDeliveryDate] DATETIME       NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

