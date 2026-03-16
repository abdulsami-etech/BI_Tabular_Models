CREATE TABLE [DWIRIS].[HubTicket] (
    [SKTicket]         INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicket]        NCHAR (18)   NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicket]), DISTRIBUTION = REPLICATE);

