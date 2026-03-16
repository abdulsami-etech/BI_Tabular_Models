CREATE VIEW [DWC].[DimAccountSCD]
AS select a.[SKAccount], a.[KeyAccount], a.[StartDateSCD], a.[EndDateSCD], a.[AccountStatus], a.[ShippingCountryCode], a.[ShippingCountry]
, a.[ShippingCountryGroup], a.[ShippingRegionPC], a.[ShippingRegionGroup], a.[ShippingGlobalRegion], a.[GroupAccounts], a.[Type]
, a.[CustomerGroup], a.[AccountSubType], a.[AccountSegmentation]
from [DW].[DimAccountSCD]  a
inner join Custom.GeographyHierarchy g on a.ShippingCountryCode = g.CountryCode
inner join dwglobal.GeographyRegion d on d.RegionGroup = g.SecRegion and d.dataset='DWC';