CREATE TABLE [Custom].[IDSTreatmentStatus] (
    [TreatmentStatusId]          INT          NOT NULL,
    [TreatmentStatusDescription] VARCHAR (80) NOT NULL,
    [DateInserted]               DATETIME     NOT NULL
)
WITH (CLUSTERED INDEX([TreatmentStatusId]), DISTRIBUTION = REPLICATE);

