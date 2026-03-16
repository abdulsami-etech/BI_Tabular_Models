CREATE VIEW [TABIRIS].[FactCaseDownload]
AS SELECT [ID]
      ,[SourceSystem]
      ,[SKCase]
      ,[KeyCase]
      ,[ACSFileRevision]
      ,[FileType]
	  ,[FileDescription]=case when FileType=1 then 'STL (no color)'
							  when FileType=2 then 'PLY (color)'
							  when FileType=3 then 'STL + PLY'
						      else 'Unknown'
						end 
      ,[DownloadedByClientID]
      ,[DownloadDate]
      ,[DownloadCount]
      ,[SKDateTime]
  FROM [DWIRIS].[FactCaseDownload];