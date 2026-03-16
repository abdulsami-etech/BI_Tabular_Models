CREATE TABLE [Custom].[AnomalyResult]
(
[ID] [int] IDENTITY(1,1) NOT NULL,
[Detector] [nvarchar](50) NULL,
[Measure] [int] NULL,
[DateInserted] [datetime] NULL,
[Anomaly] [bit] NULL
)
WITH
(
DISTRIBUTION = ROUND_ROBIN,
CLUSTERED COLUMNSTORE INDEX
)