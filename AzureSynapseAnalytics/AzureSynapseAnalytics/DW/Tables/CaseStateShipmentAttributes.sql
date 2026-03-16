CREATE TABLE [DW].[CaseStateShipmentAttributes] (
    [DWBatchID]           INT             NOT NULL,
    [SAPOrderNumber]      INT             NOT NULL,
    [StartDate]           DATETIME        NOT NULL,
    [ScanType]            NVARCHAR (400)  NULL,
    [ProductType]         NVARCHAR (400)  NULL,
    [Region]              NVARCHAR (400)  NULL,
    [Arches]              NVARCHAR (400)  NULL,
    [Backlog]             INT             NULL,
    [Capacity]            INT             NULL,
    [ComplianceIndicator] INT             NULL,
    [MassFinisher]        INT             NULL,
    [WeekNumber]          INT             NULL,
    [DayNumberOfWeek]     INT             NULL,
    [Stages]              INT             NULL,
    [FABMachineCount]     INT             NULL,
    [Expedite]            NVARCHAR (1000) NULL,
    [FABHourCapacity]     INT             NULL,
    [AFABMachineCount]    INT             NULL,
    [Rework]              INT             NULL,
    [PredictedTime]       REAL            NULL,
    [ActualTime]          REAL            NULL,
    [BacklogFactor]       REAL            NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SAPOrderNumber]));

