CREATE TABLE [DWIRIS].[HubTicketMilestone] (
    [SKTicketMilestone]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicketMilestone] NCHAR (18)   NOT NULL,
    [SourceSystemCode]   VARCHAR (10) NOT NULL,
    [DWBatchID]          INT          NOT NULL,
    [InsertDateTime]     DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicketMilestone]), DISTRIBUTION = REPLICATE);

