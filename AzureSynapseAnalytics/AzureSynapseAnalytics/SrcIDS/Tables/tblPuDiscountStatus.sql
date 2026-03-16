CREATE TABLE [SrcIDS].[tblPuDiscountStatus] (
    [LZBatchID]          INT            NOT NULL,
    [ADLSBatchID]        INT            NOT NULL,
    [ADLSTimestamp]      DATETIME2 (0)  NOT NULL,
    [discount_id]        INT            NOT NULL,
    [doctor_discount_id] INT            NOT NULL,
    [status]             SMALLINT       NOT NULL,
    [rx_form_id]         INT            NOT NULL,
    [modified_at]        DATETIME2 (7)  NULL,
    [modified_by]        NVARCHAR (50)  NOT NULL,
    [staff_role]         NVARCHAR (100) NULL,
    [_Region]            VARCHAR (32)   NOT NULL
)
WITH (CLUSTERED INDEX([discount_id]), DISTRIBUTION = HASH([discount_id]));

