CREATE TABLE [Custom].[IDSOrderType] (
    [OrderTypeId]       INT          NOT NULL,
    [OrderType]         VARCHAR (40) NOT NULL,
    [DeliverableType]   VARCHAR (40) NOT NULL,
    [TreatmentCategory] VARCHAR (40) NOT NULL,
    [DateInserted]      DATETIME     NOT NULL,
    PRIMARY KEY NONCLUSTERED ([OrderTypeId] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([OrderTypeId]), DISTRIBUTION = REPLICATE);

