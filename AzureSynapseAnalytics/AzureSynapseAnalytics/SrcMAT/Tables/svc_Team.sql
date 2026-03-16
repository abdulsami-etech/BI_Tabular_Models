CREATE TABLE [SrcMAT].[svc_Team] (
    [LZBatchID]                     INT            NOT NULL,
    [ADLSBatchID]                   INT            NOT NULL,
    [ADLSTimestamp]                 DATETIME2 (0)  NOT NULL,
    [TeamID]                        INT            NOT NULL,
    [ContactTeamGenericDescription] NVARCHAR (500) NOT NULL,
    [showToExternalUser]            BIT            NOT NULL,
    [RowStatusID]                   TINYINT        NOT NULL,
    [DateCreated]                   DATETIME       NOT NULL,
    [CreatedByUserID]               INT            NOT NULL,
    [DateUpdated]                   DATETIME       NULL,
    [UpdatedByUserID]               INT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

