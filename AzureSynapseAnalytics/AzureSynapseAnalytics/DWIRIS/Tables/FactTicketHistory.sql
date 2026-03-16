CREATE TABLE [DWIRIS].[FactTicketHistory] (
    [ID]                 NCHAR (30)    NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [LZBatchID]          INT           NOT NULL,
    [DWBatchID]          INT           NOT NULL,
    [FieldType]          VARCHAR (50)  NULL,
    [OldValue]           VARCHAR (100) NULL,
    [SKDate]             INT           NOT NULL,
    [SKUser]             INT           NOT NULL,
    [SKTicket]           INT           NOT NULL,
    [SKTicketComplaint]  INT           NOT NULL,
    [SKTicketonboarding] INT           NOT NULL,
    [SKTicketTraining]   INT           NOT NULL,
    [CreatedDate]        DATETIME2 (7) NULL
)
WITH (CLUSTERED INDEX([SKDate]), DISTRIBUTION = REPLICATE);

