CREATE VIEW [DWAppLog].[DimContact] AS Select
			ClinID					as ClinID,
			PrimaryAccountNumber	as DID,
			ContactName				as ContactName,
			LineofBusiness			as LineOfBusiness,
			ProfessionalCategory	as ProfessionalCategory,
			Salutation				as Salutation,

			MailingCity				as City,
			MailingState			as [State],
			MailingPostalCode		as PostalCode,
			MailingCountry			as Country,
			MailingCountryCode		as CountryCode,
			MailingCountryGroup		as CountryGroup,
			MailingRegionPC			as RegionPC,
			MailingRegionGroup		as RegionGroup,
			MailingGlobalRegion		as GlobalRegion

		from DW.DimContact
		where ClinID IS NOT NULL
	UNION ALL
		Select

			'-1'					as ClinID,
			'Unknown'				as DID,
			'Unknown'				as ContactName,
			'Unknown'				as LineOfBusiness,
			'Unknown'				as ProfessionalCategory,
			'Unknown'				as Salutation,

			'Unknown'				as City,
			'Unknown'				as [State],
			'Unknown'				as PostalCode,
			'Unknown'				as Country,
			'Unknown'				as CountryCode,
			'Unknown'				as CountryGroup,
			'Unknown'				as RegionPC,
			'Unknown'				as RegionGroup,
			'Unknown'				as GlobalRegion;