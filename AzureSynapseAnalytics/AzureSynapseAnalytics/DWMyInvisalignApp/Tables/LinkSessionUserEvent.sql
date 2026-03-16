CREATE TABLE [DWMyInvisalignApp].[LinkSessionUserEvent] (
    [SKSessionUserEvent] BIGINT             IDENTITY (1, 1) NOT NULL,
    [SKSession]          INT                NOT NULL,
    [SKUser]             INT                NOT NULL,
    [SKEvent]            INT                NOT NULL,
    [EventDate]          DATETIMEOFFSET (7) NOT NULL,
    [EventCount]         INT                NOT NULL,
    [DWBatchID]          INT                NOT NULL,
    [InsertDateTime]     DATETIME           NULL
)
WITH (CLUSTERED INDEX([SKSession], [SKEvent], [SKUser], [EventDate]), DISTRIBUTION = REPLICATE);

