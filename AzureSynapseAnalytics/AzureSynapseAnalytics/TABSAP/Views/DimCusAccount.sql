CREATE VIEW [TABSAP].[DimCusAccount] AS select a.Account_Number__c as AccountNumber, a.Name as AccountName,a.Account_Status__c	
as AccountStatus, a.Account_Sub_Type__c as AccountSubType, a.Type as AccountType, a.ShippingCountryCode As CountryCode,
g.Country, g.CountryGroup, g.RegionPC, g.RegionGroup, g.GlobalRegion,
a.DSO_Private_Practice__c as [Dental Service Org]
,case when  a.Type is null then 'No' when a.Type like 'Group%' then 'Yes' else 'No' end as IsDSOOrder
from SrcSFDC.Account a inner join Custom.GeographyHierarchy g on a.ShippingCountryCode = g.CountryCode
where a.Account_Number__c  is not null;