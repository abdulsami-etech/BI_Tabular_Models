CREATE VIEW [DWSFMC].[Email_Tracking]
AS SELECT 	
	[Email_JobID],
	[Emailsubject],
	[EmailName],
	[Sent_Date],
	[Total_Count],
	[Open_Count],
	[Click_Count],
	[bounce_count],
	[Unsub_Count],
	[Open_Rate] ,
	[Journey_Activity_Name],
	[Journey_Flag],
	[Sent_Date_Text]
  FROM [SrcSFMC].[Email_Tracking];