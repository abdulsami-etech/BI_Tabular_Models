CREATE VIEW [DWInst].[Session_Ext]
AS SELECT [session_id]
      ,[name]
      ,[value]
      ,[BatchID]
  FROM [SrcINST].[Session_Ext];