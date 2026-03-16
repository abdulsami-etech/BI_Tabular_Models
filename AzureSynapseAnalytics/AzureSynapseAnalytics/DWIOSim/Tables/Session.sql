CREATE TABLE [DWIOSim].[Session] (
    [session_id]              UNIQUEIDENTIFIER NULL,
    [session_datetime]        DATETIME         NULL,
    [parent_session_id]       NVARCHAR (127)   NULL,
    [auto_session_id]         INT              NULL,
    [application_version]     NVARCHAR (127)   NULL,
    [clinician_id]            NVARCHAR (127)   NULL,
    [timezone]                NVARCHAR (6)     NULL,
    [launch_type]             NVARCHAR (30)    NULL,
    [max_actionid]            BIGINT           NULL,
    [CreateSimulationActions] INT              NULL,
    [ProgressAssessment]      INT              NULL,
    [WidgetActions]           INT              NULL,
    [TreatmentGoals]          INT              NULL,
    [AllowIPRActions]         INT              NULL,
    [ExtractionActions]       INT              NULL,
    [APCorrectionActions]     INT              NULL,
    [Unmovable]               INT              NULL,
    [Compare_with_Original]   INT              NULL,
    [Direct_Submission]       INT              NULL,
    [ClinID]                  NVARCHAR (50)    NULL,
    [DWBatchID]               INT              DEFAULT ((0)) NOT NULL,
    [InsertDateTime]          DATETIME         NULL,
    [ShareSimulation]         INT              NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

