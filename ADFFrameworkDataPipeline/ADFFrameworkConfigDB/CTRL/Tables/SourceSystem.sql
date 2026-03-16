CREATE TABLE [CTRL].[SourceSystem] (
    [SourceSystem]              VARCHAR (32)   NOT NULL,
    [SourceSystemType]          VARCHAR (32)   NOT NULL,
    [ObjectDelimeter1]          VARCHAR (1)    NOT NULL,
    [ObjectDelimeter2]          VARCHAR (1)    NOT NULL,
    [DateTimeFormat]            VARCHAR (32)   NOT NULL,
    [DateTimeFormat1]           VARCHAR (16)   NOT NULL,
    [DateTimeFormat2]           VARCHAR (16)   NOT NULL,
    [MaxPredicateQueryTemplate] VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_SourceSystem] PRIMARY KEY CLUSTERED ([SourceSystem] ASC)
);

