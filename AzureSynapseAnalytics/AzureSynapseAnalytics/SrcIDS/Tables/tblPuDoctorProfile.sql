CREATE TABLE [SrcIDS].[tblPuDoctorProfile] (
    [LZBatchID]                 INT            NOT NULL,
    [ADLSBatchID]               INT            NOT NULL,
    [ADLSTimestamp]             DATETIME2 (0)  NOT NULL,
    [doctor_profile_id]         INT            NOT NULL,
    [master_user_id]            INT            NOT NULL,
    [notification_email]        NVARCHAR (50)  NULL,
    [notification_option]       BIT            NOT NULL,
    [patient_list_settings]     NVARCHAR (100) NULL,
    [changed_by]                NVARCHAR (50)  NOT NULL,
    [create_date]               DATETIME2 (7)  NOT NULL,
    [disable_date]              DATETIME2 (7)  NULL,
    [setup_counter]             INT            NOT NULL,
    [set_up]                    INT            NOT NULL,
    [locale_id]                 INT            NULL,
    [event_notification]        BIT            NULL,
    [event_notification_email]  NVARCHAR (50)  NULL,
    [notification_events]       NVARCHAR (500) NULL,
    [license_id]                NVARCHAR (20)  NULL,
    [mat_login_id]              NVARCHAR (50)  NULL,
    [clincheck_app]             NVARCHAR (30)  NULL,
    [practice_name]             NVARCHAR (150) NULL,
    [patient_list_view]         INT            NULL,
    [patient_notification_type] INT            NULL,
    [modified_at]               DATETIME2 (7)  NULL,
    [_Region]                   VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([master_user_id]), DISTRIBUTION = ROUND_ROBIN);

