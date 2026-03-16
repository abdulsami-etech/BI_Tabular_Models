CREATE TABLE [SrcMesOMS].[ScheduleHour] (
    [LZBatchID]          INT             NOT NULL,
    [ADLSBatchID]        INT             NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)   NOT NULL,
    [scheduleHourID]     INT             NOT NULL,
    [scheduleID]         INT             NOT NULL,
    [startTime]          NVARCHAR (80)   NULL,
    [endTime]            NVARCHAR (80)   NULL,
    [weekDay]            NVARCHAR (80)   NOT NULL,
    [weekDayNumber]      INT             NOT NULL,
    [effectiveWorkHours] DECIMAL (18, 2) NOT NULL,
    [hasChangeDay]       BIT             NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

