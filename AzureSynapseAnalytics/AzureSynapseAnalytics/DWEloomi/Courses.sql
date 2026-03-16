CREATE VIEW [DWEloomi].[Courses]
AS SELECT [id]
      ,[name]
      ,[description]
      ,[description_extended]
      ,[course_type]
      ,[created_at]
      ,[updated_at]
  FROM [SrcEloomi].[courses];
