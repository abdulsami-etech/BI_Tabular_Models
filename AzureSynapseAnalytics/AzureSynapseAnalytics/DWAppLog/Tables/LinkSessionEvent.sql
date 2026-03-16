CREATE TABLE [DWAppLog].[LinkSessionEvent] (
    [SKSessionEvent]   INT                IDENTITY (1, 1) NOT NULL,
    [SKSession]        INT                NOT NULL,
    [SKEvent]          INT                NOT NULL,
    [EventDate]        DATETIMEOFFSET (7) NOT NULL,
    [EventCount]       INT                NOT NULL,
    [DWBatchID]        INT                NOT NULL,
    [InsertDateTime]   DATETIME           NULL,
    [SourceSystemCode] VARCHAR (10)       NOT NULL
)
WITH
(
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = HASH(SKSession),
    PARTITION
    (
        EventDate RANGE RIGHT FOR VALUES
        (
            '1988-01-01', '2020-01-01', '2021-01-01',
            '2021-05-01', '2021-09-01', '2022-01-01',
            '2022-05-01', '2022-09-01', '2023-01-01',
            '2023-05-01', '2023-09-01', '2024-01-01',
            '2024-05-01', '2024-09-01', '2025-01-01'
        )
    )
);

