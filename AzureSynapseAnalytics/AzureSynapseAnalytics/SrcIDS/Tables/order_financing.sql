CREATE TABLE [SrcIDS].[order_financing] (
    [LZBatchID]            INT           NOT NULL,
    [ADLSBatchID]          INT           NOT NULL,
    [ADLSTimestamp]        DATETIME2 (0) NOT NULL,
    [loan_id]              NVARCHAR (35) NULL,
    [treatment_fee]        FLOAT (53)    NULL,
    [approved_loan_amount] FLOAT (53)    NULL,
    [po_number]            NVARCHAR (35) NULL,
    [vip_order_id]         INT           NOT NULL,
    [_Region]              VARCHAR (32)  NOT NULL
)
WITH (CLUSTERED INDEX([vip_order_id]), DISTRIBUTION = HASH([vip_order_id]));

