CREATE VIEW [DWEloomi].[Categories]
AS SELECT  [id]
      ,[name]
      ,[parent_id]
      ,[type]
  FROM [SrcEloomi].[categories];
GO