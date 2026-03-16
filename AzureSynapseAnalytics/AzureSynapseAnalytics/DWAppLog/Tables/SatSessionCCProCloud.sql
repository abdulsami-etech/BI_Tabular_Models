CREATE TABLE [DWAppLog].[SatSessionCCProCloud] (
    [SKSession]                      INT             NOT NULL,
    [ADLSBatchID]                    INT             NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0)   NOT NULL,
    [LZBatchID]                      INT             NOT NULL,
    [DWBatchID]                      INT             NOT NULL,
    [DWHash]                         CHAR (40)       NOT NULL,
    [event_caseId]                   NVARCHAR (50)   NULL,
    [event_clinCheckType]            NVARCHAR (255)  NULL,
    [event_date]                     NVARCHAR (255)  NULL,
    [event_deviceId]                 NVARCHAR (255)  NULL,
    [event_browser_devicePixelRatio] NVARCHAR (255)  NULL,
    [event_browser_isTouchDevice]    NVARCHAR (10)   NULL,
    [event_browser_language]         NVARCHAR (255)  NULL,
    [level]                          NVARCHAR (10)   NULL,
    [event_ts]                       datetimeoffset  NULL,
    [event_browser_userAgent]        NVARCHAR (500)  NULL,
    [event_version]                  NVARCHAR (4000) NULL,
    [event_browser_viewPortHeight]   NVARCHAR (10)   NULL,
    [event_browser_viewPortWidth]    NVARCHAR (10)   NULL,
    [event_user]                     NVARCHAR (255)  NULL,
    [ccid]                           NVARCHAR (20)   NULL,
    [SAPOrderNumber]                 BIGINT          NULL,
    [event_browser_name]             NVARCHAR (250)  NULL,
    [flow]                           NVARCHAR (50)   NULL,
    Is2MinCC                         INT             NOT NULL DEFAULT(0),
    SKOrder                          BIGINT          NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH(SKSession),
    PARTITION
    (
        event_ts RANGE RIGHT FOR VALUES
        (
            '1980-01-01', '2020-01-01', '2021-01-01',
            '2021-05-01', '2021-09-01', '2022-01-01',
            '2022-05-01', '2022-09-01', '2023-01-01',
            '2023-05-01', '2023-09-01', '2024-01-01',
            '2024-05-01', '2024-09-01', '2025-01-01'
        )
    )
);

