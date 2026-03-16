CREATE TABLE [DW].[CaseStateTraining] (
    [SourceSystem]    VARCHAR (25)   NOT NULL,
    [OperationName]   NVARCHAR (201) NULL,
    [DeliverableType] NVARCHAR (225) NULL,
    [CountryCode]     NVARCHAR (225) NULL,
    [Type]            VARCHAR (9)    NOT NULL,
    [Deviation1]      FLOAT (53)     NULL,
    [Deviation2]      FLOAT (53)     NULL,
    [Deviation3]      FLOAT (53)     NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN);

