CREATE TABLE [SrcMAT].[svc_VirtualProduct_EquipmentLink] (
    [LZBatchID]                      INT           NOT NULL,
    [ADLSBatchID]                    INT           NOT NULL,
    [ADLSTimestamp]                  DATETIME2 (0) NOT NULL,
    [VirtualProductID]               INT           NOT NULL,
    [VirtualProduct_EquipmentLinkID] INT           NOT NULL,
    [EquipmentCardID]                INT           NOT NULL,
    [RowStatusID]                    INT           NOT NULL,
    [DateCreated]                    DATETIME      NOT NULL,
    [CreatedByUserID]                INT           NOT NULL,
    [DateUpdated]                    DATETIME      NOT NULL,
    [UpdatedByUserID]                INT           NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

