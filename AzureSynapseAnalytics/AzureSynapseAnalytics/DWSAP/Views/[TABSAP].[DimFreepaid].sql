--BI-12996 New View
CREATE VIEW [TABSAP].[DimFreepaid] AS 
Select 
  'Free' as [Free_Paid] 
Union 
Select 
  'Paid' as [Free_Paid] 
Union 
Select 
  'Error' as [Free_Paid];
