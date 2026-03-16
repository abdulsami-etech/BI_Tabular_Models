CREATE TABLE [SrcSFMC].[EMEAEmailData] (
    [LZBatchID]             INT             NOT NULL,
    [ADLSBatchID]           INT             NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)   NOT NULL,
    [Email_JobId]           VARCHAR (200)   NOT NULL,
    [Emailsubject]          VARCHAR (200)   NULL,
    [EmailName]             VARCHAR (200)   NULL,
    [Sent_Date]             VARCHAR (19)    NULL,
    [Total_Count]           INT             NULL,
    [Open_Count]            INT             NULL,
    [Click_Count]           INT             NULL,
    [Bounce_Count]          INT             NULL,
    [Unsub_Count]           INT             NULL,
    [Open_Rate]             DECIMAL (12, 2) NULL,
    [Journey_Activity_Name] VARCHAR (200)   NULL,
    [Journey_Flag]          VARCHAR (10)    NULL,
    [Sent_Date_Text]        DATETIME        NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

