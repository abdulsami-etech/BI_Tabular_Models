CREATE TABLE [SrcGoogleBigQuery].[AlignerSetting] (
    [LZBatchID]                     INT            NOT NULL,
    [ADLSBatchID]                   INT            NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0)  NOT NULL,
    [event_timestamp]               BIGINT         NOT NULL,
    [event_name]                    NVARCHAR (255) NOT NULL,
    [user_pseudo_id]                NVARCHAR (255) NOT NULL,
    [_count]                        INT            NOT NULL,
    [event_date]                    DATE           NULL,
    [Current_Aligner_Set]           INT            NULL,
    [Days_Wearning_EachAligner]     INT            NULL,
    [NumberOfAligners]              INT            NULL,
    [Next_Aligner_Change_Date]      NVARCHAR (255) NULL,
    [TimeOfDay]                     NVARCHAR (255) NULL,
    [event_server_timestamp_offset] BIGINT         NULL
)
WITH (CLUSTERED INDEX([event_timestamp], [event_name], [user_pseudo_id]), DISTRIBUTION = ROUND_ROBIN);

