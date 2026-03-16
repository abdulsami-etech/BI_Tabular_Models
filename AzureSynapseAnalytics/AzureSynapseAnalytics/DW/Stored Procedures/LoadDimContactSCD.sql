
CREATE PROC [DW].[LoadDimContactSCD] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id ('DW.DimContactSCDNew', 'U') is not null
		drop table DW.DimContactSCDNew

	create table DW.DimContactSCDNew with (distribution = replicate, heap) as 
	with contactHistory as (
		select	hub.SKContact							as SKContact
			,	hub.KeyContact							as KeyContact
			,	isnull(ch.ADLSBatchID, c.ADLSBatchID)	as ADLSBatchID	
			,	isnull(ch.ADLSTimestamp, c.ADLSTimestamp)	as ADLSTimestamp
			,	isnull(ch.LZBatchID, c.LZBatchID)		as LZBatchID	
			,	isnull(ch.StartDate, '1900-01-01')		as StartDate
			,   isnull(ch.EndDate, '2099-01-01')		as EndDate
			,	case when ch.ParentId is null or ch.Certification_Date__c = 'NO_HISTORY'
					then convert(date, c.Certification_Date__c)
					else convert(date, ch.Certification_Date__c)
				end										as CertificationDate
			,	case when ch.ParentId is null or ch.MailingCountryCode = 'NO_HISTORY'
					then convert(nvarchar(10), c.MailingCountryCode)
					else convert(nvarchar(10), ch.MailingCountryCode)
				end										as MailingCountryCode
			,	convert(nvarchar(256), gh.Country)		as MailingCountry
			,	convert(nvarchar(256), gh.CountryGroup)	as MailingCountryGroup
			,	convert(nvarchar(256), gh.RegionPC)		as MailingRegionPC
			,	convert(nvarchar(256), gh.RegionGroup)	as MailingRegionGroup
			,	convert(nvarchar(256), gh.GlobalRegion)	as MailingGlobalRegion
			,	case when ch.ParentId is null or ch.Professional_Category__c = 'NO_HISTORY'
					then convert(nvarchar(50), c.Professional_Category__c)
					else convert(nvarchar(50), ch.Professional_Category__c)
				end										as ProfessionalCategory
			,	case when ch.ParentId is null or ch.CF_Training_Completion_Date__c = 'NO_HISTORY'
					then convert(date,  c.CF_Training_Completion_Date__c)
					else convert(date, ch.CF_Training_Completion_Date__c)
				end										as TrainingCompletionDate
			,	case when ch.ParentId is null or ch.EMEA_Segmentation__c = 'NO_HISTORY'
					then convert(nvarchar(50), c.EMEA_Segmentation__c)
					else convert(nvarchar(50), ch.EMEA_Segmentation__c)
				end										as EMEASegmentation
			,	case when ch.ParentId is null or ch.Contact_Status__c = 'NO_HISTORY'
					then convert(nvarchar(50), c.Contact_Status__c)
					else convert(nvarchar(50), ch.Contact_Status__c)
				end										as ContactStatus
			,	case when ch.ParentId is null or ch.Doctor_Segment__c = 'NO_HISTORY'
					then convert(nvarchar(50), c.Doctor_Segment__c)
					else convert(nvarchar(50), ch.Doctor_Segment__c)
				end										as DoctorSegment
		from SrcSFDC.Contact c
		inner join DW.HubContact hub on hub.KeyContact = c.Id
		left join SrcSFDC.ContactHistoryFlattened ch on c.Id = ch.ParentId
		left join Custom.GeographyHierarchy gh on gh.CountryCode =	case when ch.ParentId is null or ch.MailingCountryCode = 'NO_HISTORY'
															then c.MailingCountryCode
															else ch.MailingCountryCode
														end
	), ILEHistory as (
		select top (1) with ties --only 1 historical row per contact and start date
				l.SKContact							as SKContact
			,	l.StartDate							as StartDate
			,	l.Apttus_Config2__LoyaltyLevel__c	as AdvCurrentAdvantageLevel
			,	pr.Program_Code__c					as AdvCurrentAdvantageProgram
			,	pr.Current_Status__c				as AdvRegistrationStatus
		from (
			select	hub.SKContact										as SKContact
				,	isnull(h.StartDate, '1900-01-01')					as StartDate
				,	case when h.ParentId is null or h.Program_Registration__c = 'NO_HISTORY'
						then l.Program_Registration__c
						else h.Program_Registration__c
					end													as Program_Registration__c
				,	case when h.ParentId is null or h.Apttus_Config2__Active__c = 'NO_HISTORY'
						then l.Apttus_Config2__Active__c
						else h.Apttus_Config2__Active__c
					end													as Apttus_Config2__Active__c
				,	case when h.ParentId is null or h.Apttus_Config2__LoyaltyLevel__c = 'NO_HISTORY'
						then l.Apttus_Config2__LoyaltyLevel__c
						else h.Apttus_Config2__LoyaltyLevel__c
					end													as Apttus_Config2__LoyaltyLevel__c
				,	case when h.ParentId is null or h.Apttus_Config2__CustomerType__c = 'NO_HISTORY'
						then l.Apttus_Config2__CustomerType__c
						else h.Apttus_Config2__CustomerType__c
					end													as Apttus_Config2__CustomerType__c
			from SrcSFDC.Apttus_Config2__IncentiveLoyaltyEnrollment__c l
			inner join DW.HubContact hub on hub.KeyContact = l.Apttus_Config2__ContactId__c
			left join SrcSFDC.Apttus_Config2__IncentiveLoyaltyEnrollment__HistoryFlattened h on h.ParentId = l.Id
		) l
		inner join SrcSFDC.Program_Registration__c pr on pr.Id = l.Program_Registration__c
		where l.Apttus_Config2__Active__c in ('true' , '1')
			and pr.Program_Code__c in ( --logic provided by Swaran
				select Program_Code__c from SrcSFDC.Advantage_Eligibility_Check__c
				union 
				select Loyalty_Code__c from SrcSFDC.APAC_Advantage_Eligibility_Check__c		
			)
		order by row_number() over (
			partition by l.SKContact, l.StartDate
			order by case when pr.Current_Status__c = l.Apttus_Config2__CustomerType__c then 0 else 1 end --this logic was provided by Geen, required for EMEA because of NCP
		)
	), ILEHistoryWithEndDate as (
		select	SKContact
			,	StartDate
			,	lead(StartDate, 1, '2099-01-01') over (partition by SKContact order by StartDate) as EndDate
			,	AdvCurrentAdvantageLevel
			,	AdvCurrentAdvantageProgram
			,	AdvRegistrationStatus
		from ILEHistory
	), mergeContactWithILE as (
		select	a.SKContact as SKContact
			,	a.KeyContact as KeyContact
			,	a.ADLSBatchID as ADLSBatchID	
			,	a.ADLSTimestamp as ADLSTimestamp
			,	a.LZBatchID as LZBatchID	
			,	case when a.StartDate > b.StartDate then a.StartDate else isnull(b.StartDate, a.StartDate) end as StartDate
			,	case when a.EndDate < b.EndDate then a.EndDate else isnull(b.EndDate, a.EndDate) end as EndDate
			,	a.CertificationDate
			,	a.MailingCountryCode
			,	a.MailingCountry
			,	a.MailingCountryGroup
			,	a.MailingRegionPC
			,	a.MailingRegionGroup
			,	a.MailingGlobalRegion
			,	a.ProfessionalCategory
			,	a.TrainingCompletionDate
			,	a.EMEASegmentation
			,	a.ContactStatus
			,	a.DoctorSegment
			,	b.AdvCurrentAdvantageLevel
			,	b.AdvCurrentAdvantageProgram
			,	b.AdvRegistrationStatus
		from contactHistory a
		left join ILEHistoryWithEndDate b on b.SKContact = a.SKContact --we already have a full range history for contact, so can do left join instead of full
					and (
							(
								b.StartDate >= a.StartDate
								and b.StartDate < a.EndDate
							) or (
								b.EndDate > a.StartDate
								and b.EndDate <= a.EndDate
							) or (
								b.StartDate < a.StartDate
								and b.EndDate >= a.EndDate
							) 
					)
	)
	select	SKContact
		,	KeyContact
		,	ADLSBatchID	
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID as DWBatchID
		,	StartDate as StartDateSCD
		,	EndDate as EndDateSCD
		,	CertificationDate
		,	MailingCountryCode
		,	MailingCountry
		,	MailingCountryGroup
		,	MailingRegionPC
		,	MailingRegionGroup
		,	MailingGlobalRegion
		,	ProfessionalCategory
		,	TrainingCompletionDate
		,	EMEASegmentation
		,	ContactStatus
		,	DoctorSegment
		,	AdvCurrentAdvantageLevel
		,	AdvCurrentAdvantageProgram
		,	AdvRegistrationStatus
	from mergeContactWithILE

	if object_id ('DW.DimContactSCD', 'U') is not null
	begin
		if object_id ('DW.DimContactSCDPrevious', 'U') is not null
			drop table DW.DimContactSCDPrevious

		rename object DW.DimContactSCD to DimContactSCDPrevious
		rename object DW.DimContactSCDNew to DimContactSCD
		drop table DW.DimContactSCDPrevious
	end
	else
	begin
		rename object DW.DimContactSCDNew to DimContactSCD
	end

	alter table DW.DimContactSCD add constraint PK_DimContactSCD primary key nonclustered (SKContact, StartDateSCD) not enforced

	select @RowsInserted = count(*) 
	from DW.DimContactSCD

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated 

end




