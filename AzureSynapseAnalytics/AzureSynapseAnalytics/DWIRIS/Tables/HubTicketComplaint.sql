CREATE TABLE [DWIRIS].[HubTicketComplaint] (
    [SKTicketComplaint]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicketComplaint] NCHAR (18)   NOT NULL,
    [DWBatchID]          INT          NOT NULL,
    [InsertDateTime]     DATETIME     NOT NULL,
    [SourceSystemCode]   VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicketComplaint]), DISTRIBUTION = REPLICATE);

