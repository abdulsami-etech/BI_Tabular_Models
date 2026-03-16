CREATE VIEW [TABSAP].[DimFreepaid] AS 
--BI-12996 New View
Select 
  'Free' as [Free_Paid] 
Union 
Select 
  'Paid' as [Free_Paid] 
Union 
Select 
  'Error' as [Free_Paid];