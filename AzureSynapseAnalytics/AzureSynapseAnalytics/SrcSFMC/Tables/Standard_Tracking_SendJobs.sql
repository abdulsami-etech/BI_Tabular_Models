CREATE TABLE [SrcSFMC].[Standard_Tracking_SendJobs] (
    [LZBatchID]                 INT             NOT NULL,
    [ADLSBatchID]               INT             NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)   NOT NULL,
    [ClientID]                  BIGINT          NOT NULL,
    [SendID]                    BIGINT          NOT NULL,
    [FromName]                  NVARCHAR (130)  NULL,
    [FromEmail]                 NVARCHAR (100)  NULL,
    [SchedTime]                 DATETIME        NULL,
    [SentTime]                  DATETIME        NULL,
    [Subject]                   NVARCHAR (1000) NULL,
    [EmailName]                 NVARCHAR (255)  NULL,
    [TriggeredSendExternalKey]  NVARCHAR (100)  NULL,
    [SendDefinitionExternalKey] NVARCHAR (100)  NULL,
    [JobStatus]                 NVARCHAR (30)   NULL,
    [PreviewURL]                NVARCHAR (300)  NULL,
    [IsMultipart]               NVARCHAR (5)    NULL,
    [Additional]                NVARCHAR (50)   NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

