CREATE TABLE [DWIRIS].[HubTicketTraining] (
    [SKTicketTraining]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicketTraining] NCHAR (18)   NOT NULL,
    [DWBatchID]         INT          NOT NULL,
    [InsertDateTime]    DATETIME     NOT NULL,
    [SourceSystemCode]  VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicketTraining]), DISTRIBUTION = REPLICATE);

