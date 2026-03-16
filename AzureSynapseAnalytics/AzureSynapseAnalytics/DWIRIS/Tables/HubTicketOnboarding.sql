CREATE TABLE [DWIRIS].[HubTicketOnboarding] (
    [SKTicketOnboarding]  INT          IDENTITY (1, 1) NOT NULL,
    [KeyTicketOnboarding] NCHAR (18)   NOT NULL,
    [DWBatchID]           INT          NOT NULL,
    [InsertDateTime]      DATETIME     NOT NULL,
    [SourceSystemCode]    VARCHAR (10) NOT NULL
)
WITH (CLUSTERED INDEX([KeyTicketOnboarding]), DISTRIBUTION = REPLICATE);

