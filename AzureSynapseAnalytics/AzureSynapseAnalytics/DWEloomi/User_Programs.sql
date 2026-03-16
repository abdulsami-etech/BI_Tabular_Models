CREATE VIEW [DWEloomi].[User_Programs]
AS SELECT 
      [program_id]
      ,[user_id]
      ,[progress]
      ,[assigned_at]
      ,[completed_at]
      ,[time_spent]
      ,[deadline]
  FROM [SrcEloomi].[user_programs];
