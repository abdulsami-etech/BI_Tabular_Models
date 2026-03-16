CREATE TABLE [SrcMesOMS].[Manager] (
    [LZBatchID]        INT           NOT NULL,
    [ADLSBatchID]      INT           NOT NULL,
    [ADLSTimestamp]    DATETIME2 (0) NOT NULL,
    [managerID]        INT           NOT NULL,
    [userID]           INT           NOT NULL,
    [createBy]         INT           NOT NULL,
    [creationDate]     DATETIME      NOT NULL,
    [isActive]         BIT           NOT NULL,
    [inChargeOfBonus]  BIT           NOT NULL,
    [modificationDate] DATETIME      NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

