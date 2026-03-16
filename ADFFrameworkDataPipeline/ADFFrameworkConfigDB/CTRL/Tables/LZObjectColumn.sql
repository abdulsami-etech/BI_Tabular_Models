CREATE TABLE [CTRL].[LZObjectColumn] (
    [LZObjectID]      INT           NOT NULL,
    [ColumnName]      VARCHAR (128) NOT NULL,
    [OrdinalPosition] INT           NOT NULL,
    [Datatype]        VARCHAR (32)  NOT NULL,
    [Length]          INT           NULL,
    [Precision]       SMALLINT      NULL,
    [Scale]           SMALLINT      NULL,
    [IsNullable]      BIT           NOT NULL,
    CONSTRAINT [PK_LZObjectColumn] PRIMARY KEY CLUSTERED ([LZObjectID] ASC, [ColumnName] ASC)
);

