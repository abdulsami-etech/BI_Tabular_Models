CREATE TABLE [SrcTPSharingEMEA].[treatment_plan_shares_v2] (
    [LZBatchID]         INT             NOT NULL,
    [ADLSBatchID]       INT             NOT NULL,
    [ADLSTimestamp]     DATETIME2 (0)   NOT NULL,
    [id]                NVARCHAR (255)  NOT NULL,
    [clinid]            NVARCHAR (255)  NULL,
    [sales_order]       INT             NULL,
    [cc_id]             INT             NULL,
    [emails]            NVARCHAR (4000) NULL,
    [displayed_extras]  NVARCHAR (1000) NULL,
    [doctor_options]    NVARCHAR (MAX)  NULL,
    [treatment_options] NVARCHAR (MAX)  NULL,
    [share_source]      NVARCHAR (32)   NULL,
    [share_type]        NVARCHAR (32)   NULL,
    [date_created]      DATETIME        NULL,
    [created_by]        NVARCHAR (MAX)  NULL,
    [disabled_at]       DATETIME        NULL,
    [disable_reason]    NVARCHAR (8)    NULL,
    [vip_order_id]      INT             NULL
)
WITH (CLUSTERED INDEX([id]), DISTRIBUTION = HASH([id]));

