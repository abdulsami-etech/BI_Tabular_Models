CREATE TABLE [Custom].[IDSTreatmentType] (
    [TreatmentTypeId] INT          NOT NULL,
    [TreatmentType]   VARCHAR (40) NOT NULL,
    [DateInserted]    DATETIME     NOT NULL,
    PRIMARY KEY NONCLUSTERED ([TreatmentTypeId] ASC) NOT ENFORCED
)
WITH (CLUSTERED INDEX([TreatmentTypeId]), DISTRIBUTION = REPLICATE);

