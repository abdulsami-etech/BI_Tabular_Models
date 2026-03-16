CREATE TABLE [DWSAP].[AASTableMarkers]
(
       [TableName] [varchar](100) NULL,
       [Marker] [varchar](100) NULL,
       [DrivingDate] [nvarchar](60) NULL,
       [AASTableName] [varchar](50) NULL,
       [DbName] [nvarchar](100) NULL
)
WITH
(
       DISTRIBUTION = ROUND_ROBIN,
       CLUSTERED COLUMNSTORE INDEX
)
