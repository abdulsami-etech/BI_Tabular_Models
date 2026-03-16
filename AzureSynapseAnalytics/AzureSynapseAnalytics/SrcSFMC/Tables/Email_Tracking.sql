CREATE TABLE [SrcSFMC].[Email_Tracking] (
    [LZBatchID]             INT            NOT NULL,
    [ADLSBatchID]           INT            NOT NULL,
    [ADLSTimestamp]         DATETIME2 (0)  NOT NULL,
    [Email_JobID]           NVARCHAR (255) NULL,
    [Emailsubject]          NVARCHAR (255) NULL,
    [EmailName]             NVARCHAR (255) NULL,
    [Sent_Date]             NVARCHAR (255) NULL,
    [Total_Count]           NVARCHAR (255) NULL,
    [Open_Count]            NVARCHAR (255) NULL,
    [Click_Count]           NVARCHAR (255) NULL,
    [bounce_count]          NVARCHAR (255) NULL,
    [Unsub_Count]           NVARCHAR (255) NULL,
    [Open_Rate]             NVARCHAR (255) NULL,
    [Journey_Activity_Name] NVARCHAR (255) NULL,
    [Journey_Flag]          NVARCHAR (255) NULL,
    [Sent_Date_Text]        NVARCHAR (255) NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

