CREATE VIEW [DWEloomi].[User_Courses]
AS SELECT [course_id]
      ,[user_id]
      ,[score]
      ,[progress]
      ,[attempts]
      ,[assigned_at]
      ,[started_at]
      ,[completed_at]
      ,Time_Spent
      ,[deadline]
  FROM [SrcEloomi].[user_courses];


