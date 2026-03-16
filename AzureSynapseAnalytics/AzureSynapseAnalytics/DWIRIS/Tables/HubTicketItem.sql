CREATE TABLE [DWIRIS].[HubTicketItem] (
    [SKTicketItem]     INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicketItem]    NCHAR (18)   NOT NULL,
    [DWBatchID]        INT          NOT NULL,
    [InsertDateTime]   DATETIME     NOT NULL,
    [SourceSystemCode] VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicketItem]), DISTRIBUTION = REPLICATE);

