CREATE TABLE [DWAppLog].[HubSession] (
    [SKSession]        INT                IDENTITY (1, 1) NOT NULL,
    [KeyTrace]         NVARCHAR (100)     NOT NULL,
    [KeyTs]            DATETIMEOFFSET (7) NOT NULL,
    [DWBatchID]        INT                NOT NULL,
    [InsertDateTime]   DATETIME           NULL,
    [SourceSystemCode] VARCHAR (10)       NOT NULL
)
WITH (    CLUSTERED COLUMNSTORE INDEX,
           DISTRIBUTION = HASH(KeyTrace)
    );

