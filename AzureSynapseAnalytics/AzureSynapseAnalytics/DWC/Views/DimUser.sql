CREATE VIEW [DWC].[DimUser]
AS select u.[SKUser], u.[KeyUser], u.[SourceSystemCode], u.[UserName], u.[FirstName], u.[LastName], u.[Alias], u.[AlignSalesRepID], u.[UserRoleName]
, u.[FederationIdentifier], u.[CreatedDate], u.[IsActive], u.[ManagerID], u.[EmpHireDate], u.[Address], u.[City]
, u.[State], u.[Country], u.[PostalCode], u.[Phone]
from [DW].[DimUser] u;