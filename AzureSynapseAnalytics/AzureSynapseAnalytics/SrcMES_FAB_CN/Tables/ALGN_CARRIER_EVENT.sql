CREATE TABLE [SrcMES_FAB_CN].[ALGN_CARRIER_EVENT] (
    [LZBatchID]          INT           NOT NULL,
    [ADLSBatchID]        INT           NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0) NOT NULL,
    [at_auto_id]         BIGINT        NOT NULL,
    [at_create_date]     DATETIME      NOT NULL,
    [trx_key]            BIGINT        NOT NULL,
    [trx_name]           NVARCHAR (50) NOT NULL,
    [trx_time]           DATETIME      NOT NULL,
    [reason]             NVARCHAR (64) NULL,
    [user_name]          NVARCHAR (64) NULL,
    [location]           NVARCHAR (64) NULL,
    [carrier_key]        BIGINT        NOT NULL,
    [source_name]        NVARCHAR (64) NULL,
    [reporting_location] NVARCHAR (64) NULL,
    [plant]              NVARCHAR (64) NULL,
    [unit_count]         INT           NULL,
    [delivery_type]      NVARCHAR (64) NULL,
    [delivery_type_code] INT           NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([trx_key]));