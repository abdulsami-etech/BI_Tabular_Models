CREATE TABLE [DW].[WeeklyCaseStateTraining] (
    [OperationName]   NVARCHAR (250) NULL,
    [IsIoscan]        NVARCHAR (10)  NULL,
    [WeekofYear]      INT            NULL,
    [Plant]           NVARCHAR (50)  NULL,
    [DeliverableType] NVARCHAR (225) NULL,
    [CountryCode]     NVARCHAR (10)  NULL,
    [Type]            NVARCHAR (25)  NOT NULL,
    [Deviation1]      FLOAT (53)     NULL,
    [Deviation2]      FLOAT (53)     NULL,
    [Deviation3]      FLOAT (53)     NULL,
    [SourceSystem]    NVARCHAR (50)  NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

