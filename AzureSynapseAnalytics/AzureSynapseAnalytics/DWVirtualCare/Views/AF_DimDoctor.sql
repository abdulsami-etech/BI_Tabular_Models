CREATE VIEW [DWVirtualCare].[AF_DimDoctor]
as

select 
	c.[ClinID],
	c.[ContactName],
	c.[ProfessionalCategory],
	c.[MailingRegionGroup],
	c.[MailingRegionPC],
	c.[MailingCountryGroup],
	c.[MailingCountry],

	g.[Country],
	g.[CountryGroup],
	g.[RegionPC],
	g.[RegionGroup],
	g.[GlobalRegion]

from [DW].[DimContact] c
	inner join 
	 (SELECT distinct [clin_id] from [SrcEventHub].[VirtualCare] where api_type='virtual-care' and event_meta_data is not NULL) v 
		on v.[clin_id]=c.[ClinID]
	left join [DW].[DimAccount] a on c.PrimarySKAccount=a.SKAccount
	left join [Custom].[GeographyHierarchy] g on g.CountryCode=a.[ShippingCountryCode]
where
c.[ContactType]='Doctor'
and c.ClinID not in ('dtest', 'ftest', 'greatsmi','tphillrf')