CREATE TABLE [SrcSFDC].[Holiday] (
    [LZBatchID]               INT            NOT NULL,
    [ADLSBatchID]             INT            NOT NULL,
    [ADLSTimestamp]           DATETIME2 (0)  NOT NULL,
    [ActivityDate]            DATETIME2 (7)  NULL,
    [CreatedById]             NCHAR (18)     NULL,
    [CreatedDate]             DATETIME2 (7)  NOT NULL,
    [Description]             NVARCHAR (100) NULL,
    [EndTimeInMinutes]        INT            NULL,
    [Id]                      NCHAR (18)     NOT NULL,
    [IsAllDay]                BIT            NOT NULL,
    [IsRecurrence]            BIT            NOT NULL,
    [LastModifiedById]        NCHAR (18)     NULL,
    [LastModifiedDate]        DATETIME2 (7)  NOT NULL,
    [Name]                    NVARCHAR (80)  NOT NULL,
    [RecurrenceDayOfMonth]    INT            NULL,
    [RecurrenceDayOfWeekMask] INT            NULL,
    [RecurrenceEndDateOnly]   DATETIME2 (7)  NULL,
    [RecurrenceInstance]      NVARCHAR (40)  NULL,
    [RecurrenceInterval]      INT            NULL,
    [RecurrenceMonthOfYear]   NVARCHAR (40)  NULL,
    [RecurrenceStartDate]     DATETIME2 (7)  NULL,
    [RecurrenceType]          NVARCHAR (40)  NULL,
    [StartTimeInMinutes]      INT            NULL,
    [SystemModstamp]          DATETIME2 (7)  NOT NULL
)
WITH (CLUSTERED INDEX([Id]), DISTRIBUTION = HASH([Id]));

