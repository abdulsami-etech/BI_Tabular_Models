CREATE TABLE [SrcMAT].[BillOfWork] (
    [LZBatchID]                    INT            NOT NULL,
    [ADLSBatchID]                  INT            NOT NULL,
    [ADLSTimestamp]                DATETIME2 (0)  NOT NULL,
    [BillOfWorkID]                 INT            NOT NULL,
    [BillOfWorkGenericDescription] NVARCHAR (100) NOT NULL,
    [AssemblyItemID]               INT            NOT NULL,
    [ResourceTypeID]               SMALLINT       NOT NULL,
    [EstimatedTimeMinutes]         INT            NULL,
    [IsInitial]                    BIT            NOT NULL,
    [RedoBillOfWorkID]             INT            NOT NULL,
    [ClientBitMask]                INT            NOT NULL,
    [DetailsDescription]           NVARCHAR (200) NULL,
    [CaseState777]                 INT            NOT NULL,
    [RowStatusID]                  TINYINT        NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [CreatedByUserID]              INT            NOT NULL,
    [DateUpdated]                  DATETIME       NOT NULL,
    [UpdatedByUserID]              INT            NOT NULL,
    [DisplayOrder]                 INT            NOT NULL,
    [SendUpdates]                  BIT            NOT NULL,
    [AssignSpecificResource]       BIT            NOT NULL,
    [AllowRedoForDifferentDetail]  BIT            NOT NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

