CREATE VIEW [TABSAP].[DimCustContact]
AS Select top (1) with ties
			c.ContactName,
			c.ClinID,			
			c.ContactType,			
			c.LineOfBusiness,
			c.MailingCity			as City,
			c.MailingCountry		as Country,
			c.MailingCountryCode	as CountryCode,
			c.ProfessionalCategory,
			c.Salutation			as Salutation,
			c.PrimaryAccountNumber	as DID,
			c.AdvCurrentAdvantageLevel as AdvantageTier ,
			c.AdvCurrentAdvantageProgram,
			c.CertificationDate,
			case when td.ClinId is not null  
			then 'Yes'  
			else 'No'  
			end as IsTestDoctor 
		from DW.[DimContact] c left join Custom.TestDoctors td on c.ClinID = td.ClinID
		where c.ClinID IS NOT NULL
		order by  			
			row_number() over (
                    partition by    c.ClinID
                    order by c.SKContact
                );