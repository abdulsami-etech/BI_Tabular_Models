CREATE TABLE [SrcMAT].[Case_Units] (
    [LZBatchID]           INT            NOT NULL,
    [ADLSBatchID]         INT            NOT NULL,
    [ADLSTimestamp]       DATETIME2 (0)  NOT NULL,
    [OrderHeaderID]       INT            NOT NULL,
    [AdaID]               TINYINT        NOT NULL,
    [UnitTypeID]          SMALLINT       NOT NULL,
    [Color]               VARCHAR (50)   NULL,
    [PrepBucc]            VARCHAR (50)   NULL,
    [PrepLing]            VARCHAR (50)   NULL,
    [MarginBucc]          VARCHAR (50)   NULL,
    [MarginLing]          VARCHAR (50)   NULL,
    [DieShade]            VARCHAR (50)   NULL,
    [MaterialTypeID]      SMALLINT       NOT NULL,
    [ToothInBridgeTypeID] SMALLINT       NOT NULL,
    [BridgeIndex]         SMALLINT       NOT NULL,
    [AdditionalDies]      SMALLINT       NOT NULL,
    [DieDitch]            TINYINT        NULL,
    [DateCreated]         DATETIME       NULL,
    [RowStatusID]         TINYINT        NULL,
    [ItemCode]            VARCHAR (50)   NOT NULL,
    [ImplantTypeID]       INT            NULL,
    [UnitTypeDisplayName] NVARCHAR (100) NULL,
    [Analog]              SMALLINT       NULL
)
WITH (HEAP, DISTRIBUTION = ROUND_ROBIN);

