CREATE TABLE [DW].[CaseStateCCAattributes] (
    [DWBatchID]       INT            NOT NULL,
    [SAPOrdernumber]  INT            NOT NULL,
    [StartDate]       DATETIME       NOT NULL,
    [ScanType]        VARCHAR (255)  NOT NULL,
    [Team]            VARCHAR (255)  NULL,
    [ProductType]     VARCHAR (255)  NULL,
    [Region]          VARCHAR (255)  NULL,
    [DDTbacklog]      INT            NULL,
    [SSbacklog]       INT            NULL,
    [DayNumberofWeek] INT            NULL,
    [WeekOfYear]      INT            NULL,
    [PriorityBucket]  INT            NULL,
    [DedicatedTech]   INT            NULL,
    [UpcomingHoliday] INT            NULL,
    [EveningShift]    INT            NULL,
    [MorningShift]    INT            NULL,
    [PredictedTime]   REAL           NULL,
    [ActualTime]      REAL           NULL,
    [Capacity]        INT            NULL,
    [TreatmentType]   NVARCHAR (400) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrdernumber]));

