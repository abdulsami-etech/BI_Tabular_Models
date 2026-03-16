CREATE TABLE [SrcNADocLoc].[Contact_Forms] (
    [LZBatchID]      INT            NOT NULL,
    [ADLSBatchID]    INT            NOT NULL,
    [ADLSTimestamp]  DATETIME2 (0)  NOT NULL,
    [id]             BIGINT         NOT NULL,
    [doc_id]         BIGINT         NULL,
    [first_name]     NVARCHAR (255) NULL,
    [last_name]      NVARCHAR (255) NULL,
    [phone_number]   NVARCHAR (255) NULL,
    [email]          NVARCHAR (255) NULL,
    [contact_method] NVARCHAR (255) NULL,
    [preferred_time] NVARCHAR (255) NULL,
    [client_ip]      NVARCHAR (255) NULL,
    [created_at]     DATETIME2 (7)  NOT NULL,
    [updated_at]     DATETIME2 (7)  NOT NULL,
    [birthday]       DATE           NULL,
    [opt_in]         BIT            NULL,
    [segment]        NVARCHAR (255) NULL,
    [zip]            NVARCHAR (255) NULL,
    [sent_to_kbm]    BIT            NULL,
    [in_ca]          BIT            NULL,
    [is_converted]   BIT            NULL,
    [prospect_id]    NVARCHAR (255) NULL,
    [lead_source]    NVARCHAR (255) NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

