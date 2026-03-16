CREATE TABLE [DWTOPS].[FactTicketComplaints] (
    [ADLSBatchID]              INT             NOT NULL,
    [ADLSTimestamp]            DATETIME2 (0)   NOT NULL,
    [LZBatchID]                INT             NOT NULL,
    [DWBatchID]                INT             NOT NULL,
    [DgnCaseNumber]            NVARCHAR (60)   NULL,
    [DgnStatus]                NVARCHAR (60)   NULL,
    [DgnCreatedDate]           DATETIME2 (0)   NULL,
    [DgnComplaintType]         NVARCHAR (510)  NULL,
    [DgnComplaintSubType]      NVARCHAR (510)  NULL,
    [DgnManufacturingSite]     NVARCHAR (255)  NULL,
    [DgnDoctor]                NVARCHAR (255)  NULL,
    [DgnRegion]                NVARCHAR (1300) NULL,
    [SKDoctor]                 INT             NOT NULL,
    [SKCreatedDate]            INT             NOT NULL,
    [SKCreatedTime]            INT             NOT NULL,
    [SkPlantOriginal]          INT             NOT NULL,
    [SkPlantActual]            INT             NOT NULL,
    [IsDesignExecution]        INT             NULL,
    [IsProductEnvelope]        INT             NULL,
    [IsSystemORSoftware]       INT             NULL,
    [IsUnspecifiedExpectation] INT             NULL,
    [IsAlignerManufacturing]   INT             NULL,
    [IsViveraRetainer]         INT             NULL,
    [IsNonValid]               INT             NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([SKDoctor]));

