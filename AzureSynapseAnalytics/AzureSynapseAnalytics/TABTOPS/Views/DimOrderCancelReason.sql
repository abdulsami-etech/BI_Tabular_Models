CREATE VIEW [TABTOPS].[DimOrderCancelReason]
AS SELECT [SKCancelReason]
      ,[CancelReasonCode]
      ,[CancelReasonName]
  FROM [DWTOPS].[DimOrderCancelReason];