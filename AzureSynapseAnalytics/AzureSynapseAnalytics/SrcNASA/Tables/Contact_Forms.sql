CREATE TABLE [SrcNASA].[Contact_Forms] (
    [LZBatchID]          INT             NOT NULL,
    [ADLSBatchID]        INT             NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)   NOT NULL,
    [id]                 BIGINT          NOT NULL,
    [first_name]         NVARCHAR (255)  NULL,
    [last_name]          NVARCHAR (255)  NULL,
    [phone]              NVARCHAR (255)  NULL,
    [email]              NVARCHAR (255)  NULL,
    [zip]                NVARCHAR (255)  NULL,
    [contact_preference] NVARCHAR (MAX)  NULL,
    [patient_age]        NVARCHAR (255)  NULL,
    [availability]       NVARCHAR (255)  NULL,
    [first_doctor]       NVARCHAR (4000) NULL,
    [second_doctor]      NVARCHAR (4000) NULL,
    [third_doctor]       NVARCHAR (4000) NULL,
    [requests]           NVARCHAR (4000) NULL,
    [created_at]         DATETIME2 (7)   NOT NULL,
    [updated_at]         DATETIME2 (7)   NOT NULL,
    [user_type]          NVARCHAR (255)  NULL,
    [date_of_birth]      VARCHAR (255)   NULL,
    [opt_in]             BIT             NULL,
    [source]             NVARCHAR (255)  NULL,
    [visitor_id]         VARCHAR (12)    NULL,
    [minutes_on_site]    VARCHAR (18)    NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

