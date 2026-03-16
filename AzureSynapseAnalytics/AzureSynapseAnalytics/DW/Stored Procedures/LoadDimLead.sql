CREATE PROC [DW].[LoadDimLead] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0), @IsForceFullLoad [bit] AS
BEGIN
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimLead') is not null
		drop table #TempDimLead

	create table #TempDimLead with (distribution = round_robin, heap) as 
		SELECT
			 l.ADLSBatchID 												AS ADLSBatchID
			,l.ADLSTimestamp 											AS ADLSTimestamp
			,l.LZBatchID 												AS LZBatchID
			,convert(char(40), '') 										AS DWHash
			,hub.SKLead													AS SKLead
			,l.Id 														AS KeyLead

			,l.[Account__c]												AS	[AccountID]
			,l.[Account_Region__c]										AS	[AccountRegion]
			,l.[Account_City__c]										AS	[AccountCity]
			,l.[Account_Postal_Code__c]									AS	[AccountPostalCode]
			,l.[Account_State__c]										AS	[AccountState]
			,l.[Account_Sub_Type_Lookup__c]								AS	[AccountSubTypeLookup]
			,l.[Account_Type__c]										AS	[AccountType]
			,l.[Adapt_Eligible__c]										AS	[AdaptEligible]
			,l.[Address_1__c]											AS	[Address1]
			,l.[Address_2__c]											AS	[Address2]
			,l.[Address_3__c]											AS	[Address3]
			,l.[Address_4__c]											AS	[Address4]
			,l.[Address_type__c]										AS	[AddressType]
			,l.[Age__c]													AS	[Age]
			,l.[ASD__c]													AS	[ASD]
			,l.[CCA_Achieved__c]										AS	[CCAAchieved]
			,l.[CCA_Patient_Count__c]									AS	[CCAPatientCount]
			,l.[City]													AS	[City]
			,CONVERT(DATE,l.[ClinCheck_Accepted_Date__c])				AS	[CCADate]
			,l.[Clinician_ID__c]										AS	[ClinID]
			,l.[Comments__c]											AS	[Comments]
			,l.[Company]												AS	[Company]
			,l.[condition_type__c]										AS	[ConditionType]
			,l.[Consult_Achieved__c]									AS	[ConsultAchieved]
			,CONVERT(DATE,l.[Consult_Date__c])							AS	[ConsultDate]
			,l.[Consult_Type__c]										AS	[ConsultType]
			,l.[Converted__c]											AS	[Converted]
			,CONVERT(DATE,l.[Converted_Date__c])						AS	[ConvertedDate]
			,l.[Converted_to_Patient__c]								AS	[ConvertedToPatient]
			,l.[Converted_to_Patient_or_CCA__c]							AS	[ConvertedToPatientOrCCA]
			,l.[Country]												AS	[Country]
			,l.[CountryCode]											AS	[CountryCode]
			,CONVERT(DATE,l.[CreatedDate])								AS	[CreatedDate]
			,l.[CreatedById]											AS	[CreatedByID]
			,l.[Days_from_Check_In_to_CCA__c]							AS	[DaysFromCheckInToCCA]
			,l.[Days_from_Consult_Date_to_CCA_Date__c]					AS	[DaysFromConsultToCCA]
			,l.[Days_from_First_Contact_to_Consult_Date__c]				AS	[DaysFromFirstContactToConsult]
			,l.[Days_from_Scheduled_to_Consult__c]						AS	[DaysFromScheduledtoConsult]
			,l.[Days_to_CCA_from_First_Contact__c]						AS	[DaysToCCAFromFrstContact]
			,l.[Days_to_Close_for_Consult__c]							AS	[DaysToCloseFromConsult]
			,l.[Days_to_Convert_from_Consult__c]						AS	[DaysToConvertFromConsult]
			,l.[Days_to_Convert_from_First_Contact__c]					AS	[DaystoConvertFromFirstContact]
			,l.[DID__c]													AS	[DID]
			,l.[DID_Number__c]											AS	[DIDNumber]
			,l.[Finance__c]												AS	[Finance]
			,CONVERT(DATE,l.[First_Contact__c])							AS	[FirstContactDate]
			,l.[Gender__c]												AS	[Gender]
			,l.[HasOptedOutOfEmail]										AS	[HasOptedOutOfEmail]
			,l.[I_am__c]												AS	[Iam]
			,l.[IsConverted]											AS	[IsConverted]
			,l.[Lead_Score__c]											AS	[LeadScore]
			,l.[Lead_URL_Campaign__c]									AS	[LeadURLCampaign]
			,l.[Lead_URL_Medium__c]										AS	[LeadURLMedium]
			,l.[Lead_URL_Source__c]										AS	[LeadURLSource]
			,l.[Lead_URL_Term__c]										AS	[LeadURLTerm]
			,l.[LeadSource]												AS	[LeadSource]
			,l.[OwnerId]												AS	[OwnerID]
			,l.[Patient__c]												AS	[PatientID]
			,l.[PCS_Territory__c]										AS	[PCSTerritory]
			,l.[PCS_Territory_Agent__c]									AS	[PCSTerritoryAgent]
			,l.[Primary_Goal__c]										AS	[PrimaryGoal]
			,l.[Prospect_Id__c]											AS	[ProspectID]
			,l.[Prospect_Status__c]										AS	[ProspectStatus]
			,rt.[Name]													AS	[RecordType]
			,l.[Smile_Visualization__c]									AS	[SmileVisualization]
			,l.[SmileView__c]											AS	[SmileView]
			,l.[State__c]												AS	[State]
			,l.[Status]													AS	[Status]
			,l.[Test_Lead__c]											AS	[TestLead]
			,l.[Zip__c]													AS	[ZIP]
			,l.[Lead_Region__c]											AS	[LeadRegion]
			,l.[Et4ae5__HasOptedOutOfMobile__C]							AS	[HasOptedOutOfMobile]
			,DimReg.SecRegion

	FROM SrcSFDC.Lead l
		INNER JOIN DW.HubLead hub on hub.KeyLead=l.Id
		LEFT JOIN SrcSFDC.RecordType rt on rt.Id=l.[RecordTypeId]
		LEFT JOIN Custom.GeographyHierarchy DimReg on l.[CountryCode]=DimReg.CountryCode

	update #TempDimLead set DWHash=
		convert(char(40),
			hashbytes('SHA1',
									 isnull(convert(nvarchar, [AccountID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountRegion]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountCity]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountPostalCode]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountState]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountSubTypeLookup]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AccountType]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AdaptEligible]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Address1]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Address2]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Address3]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Address4]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [AddressType]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Age]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ASD]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CCAAchieved]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CCAPatientCount]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [City]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CCADate]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ClinID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Comments]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Company]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConditionType]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConsultAchieved]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConsultDate]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConsultType]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Converted]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConvertedDate]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConvertedToPatient]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ConvertedToPatientOrCCA]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Country]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CountryCode]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CreatedDate]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [CreatedByID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysFromCheckInToCCA]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysFromConsultToCCA]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysFromFirstContactToConsult]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysFromScheduledtoConsult]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysToCCAFromFrstContact]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysToCloseFromConsult]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaysToConvertFromConsult]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DaystoConvertFromFirstContact]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [DIDNumber]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Finance]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [FirstContactDate]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Gender]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [HasOptedOutOfEmail]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Iam]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [IsConverted]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadScore]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadURLCampaign]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadURLMedium]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadURLSource]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadURLTerm]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadSource]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [OwnerID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [PatientID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [PCSTerritory]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [PCSTerritoryAgent]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [PrimaryGoal]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ProspectID]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ProspectStatus]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [RecordType]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [SmileVisualization]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [SmileView]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [State]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [Status]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [TestLead]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [ZIP]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [LeadRegion]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [HasOptedOutOfMobile]), N'N/A')
							+ N'|' + isnull(convert(nvarchar, [SecRegion]), N'N/A')

				)
			, 2)

	if @IsForceFullLoad=1 truncate table DW.DimLead 

	if not exists (select * from DW.DimLead where SKLead = -1)
	begin
		declare @Hash char(40) = ''
			,	@CurrentDate datetime2(7) = getdate()

		insert into DW.DimLead (
				SKLead
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyLead

		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
		)
	end

	update DW.DimLead
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash

		,[AccountID] =src.[AccountID]
		,[AccountRegion] =src.[AccountRegion]
		,[AccountCity] =src.[AccountCity]
		,[AccountPostalCode] =src.[AccountPostalCode]
		,[AccountState] =src.[AccountState]
		,[AccountSubTypeLookup] =src.[AccountSubTypeLookup]
		,[AccountType] =src.[AccountType]
		,[AdaptEligible] =src.[AdaptEligible]
		,[Address1] =src.[Address1]
		,[Address2] =src.[Address2]
		,[Address3] =src.[Address3]
		,[Address4] =src.[Address4]
		,[AddressType] =src.[AddressType]
		,[Age] =src.[Age]
		,[ASD] =src.[ASD]
		,[CCAAchieved] =src.[CCAAchieved]
		,[CCAPatientCount] =src.[CCAPatientCount]
		,[City] =src.[City]
		,[CCADate] =src.[CCADate]
		,[ClinID] =src.[ClinID]
		,[Comments] =src.[Comments]
		,[Company] =src.[Company]
		,[ConditionType] =src.[ConditionType]
		,[ConsultAchieved] =src.[ConsultAchieved]
		,[ConsultDate] =src.[ConsultDate]
		,[ConsultType] =src.[ConsultType]
		,[Converted] =src.[Converted]
		,[ConvertedDate] =src.[ConvertedDate]
		,[ConvertedToPatient] =src.[ConvertedToPatient]
		,[ConvertedToPatientOrCCA] =src.[ConvertedToPatientOrCCA]
		,[Country] =src.[Country]
		,[CountryCode] =src.[CountryCode]
		,[CreatedDate] =src.[CreatedDate]
		,[CreatedByID] =src.[CreatedByID]
		,[DaysFromCheckInToCCA] =src.[DaysFromCheckInToCCA]
		,[DaysFromConsultToCCA] =src.[DaysFromConsultToCCA]
		,[DaysFromFirstContactToConsult] =src.[DaysFromFirstContactToConsult]
		,[DaysFromScheduledtoConsult] =src.[DaysFromScheduledtoConsult]
		,[DaysToCCAFromFrstContact] =src.[DaysToCCAFromFrstContact]
		,[DaysToCloseFromConsult] =src.[DaysToCloseFromConsult]
		,[DaysToConvertFromConsult] =src.[DaysToConvertFromConsult]
		,[DaystoConvertFromFirstContact] =src.[DaystoConvertFromFirstContact]
		,[DID] =src.[DID]
		,[DIDNumber] =src.[DIDNumber]
		,[Finance] =src.[Finance]
		,[FirstContactDate] =src.[FirstContactDate]
		,[Gender] =src.[Gender]
		,[HasOptedOutOfEmail] =src.[HasOptedOutOfEmail]
		,[Iam] =src.[Iam]
		,[IsConverted] =src.[IsConverted]
		,[LeadScore] =src.[LeadScore]
		,[LeadURLCampaign] =src.[LeadURLCampaign]
		,[LeadURLMedium] =src.[LeadURLMedium]
		,[LeadURLSource] =src.[LeadURLSource]
		,[LeadURLTerm] =src.[LeadURLTerm]
		,[LeadSource] =src.[LeadSource]
		,[OwnerID] =src.[OwnerID]
		,[PatientID] =src.[PatientID]
		,[PCSTerritory] =src.[PCSTerritory]
		,[PCSTerritoryAgent] =src.[PCSTerritoryAgent]
		,[PrimaryGoal] =src.[PrimaryGoal]
		,[ProspectID] =src.[ProspectID]
		,[ProspectStatus] =src.[ProspectStatus]
		,[RecordType] =src.[RecordType]
		,[SmileVisualization] =src.[SmileVisualization]
		,[SmileView] =src.[SmileView]
		,[State] =src.[State]
		,[Status] =src.[Status]
		,[TestLead] =src.[TestLead]
		,[ZIP] =src.[ZIP]
		,[LeadRegion] =src.[LeadRegion]
		,[HasOptedOutOfMobile] =src.[HasOptedOutOfMobile]
		,[SecRegion]=src.[SecRegion]
		
	from #TempDimLead src
	where DW.DimLead.SKLead = src.SKLead
		and DW.DimLead.DWHash != src.DWHash
	option (label = 'DW.LoadDimLead_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLead_Update', @rc = @RowsUpdated out


	insert into DW.DimLead (
			SKLead
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyLead

		,[AccountID]
		,[AccountRegion]
		,[AccountCity]
		,[AccountPostalCode]
		,[AccountState]
		,[AccountSubTypeLookup]
		,[AccountType]
		,[AdaptEligible]
		,[Address1]
		,[Address2]
		,[Address3]
		,[Address4]
		,[AddressType]
		,[Age]
		,[ASD]
		,[CCAAchieved]
		,[CCAPatientCount]
		,[City]
		,[CCADate]
		,[ClinID]
		,[Comments]
		,[Company]
		,[ConditionType]
		,[ConsultAchieved]
		,[ConsultDate]
		,[ConsultType]
		,[Converted]
		,[ConvertedDate]
		,[ConvertedToPatient]
		,[ConvertedToPatientOrCCA]
		,[Country]
		,[CountryCode]
		,[CreatedDate]
		,[CreatedByID]
		,[DaysFromCheckInToCCA]
		,[DaysFromConsultToCCA]
		,[DaysFromFirstContactToConsult]
		,[DaysFromScheduledtoConsult]
		,[DaysToCCAFromFrstContact]
		,[DaysToCloseFromConsult]
		,[DaysToConvertFromConsult]
		,[DaystoConvertFromFirstContact]
		,[DID]
		,[DIDNumber]
		,[Finance]
		,[FirstContactDate]
		,[Gender]
		,[HasOptedOutOfEmail]
		,[Iam]
		,[IsConverted]
		,[LeadScore]
		,[LeadURLCampaign]
		,[LeadURLMedium]
		,[LeadURLSource]
		,[LeadURLTerm]
		,[LeadSource]
		,[OwnerID]
		,[PatientID]
		,[PCSTerritory]
		,[PCSTerritoryAgent]
		,[PrimaryGoal]
		,[ProspectID]
		,[ProspectStatus]
		,[RecordType]
		,[SmileVisualization]
		,[SmileView]
		,[State]
		,[Status]
		,[TestLead]
		,[ZIP]
		,[LeadRegion]
		,[HasOptedOutOfMobile]
		,[SecRegion]

	)
	select	src.SKLead
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyLead

		,src.[AccountID]
		,src.[AccountRegion]
		,src.[AccountCity]
		,src.[AccountPostalCode]
		,src.[AccountState]
		,src.[AccountSubTypeLookup]
		,src.[AccountType]
		,src.[AdaptEligible]
		,src.[Address1]
		,src.[Address2]
		,src.[Address3]
		,src.[Address4]
		,src.[AddressType]
		,src.[Age]
		,src.[ASD]
		,src.[CCAAchieved]
		,src.[CCAPatientCount]
		,src.[City]
		,src.[CCADate]
		,src.[ClinID]
		,src.[Comments]
		,src.[Company]
		,src.[ConditionType]
		,src.[ConsultAchieved]
		,src.[ConsultDate]
		,src.[ConsultType]
		,src.[Converted]
		,src.[ConvertedDate]
		,src.[ConvertedToPatient]
		,src.[ConvertedToPatientOrCCA]
		,src.[Country]
		,src.[CountryCode]
		,src.[CreatedDate]
		,src.[CreatedByID]
		,src.[DaysFromCheckInToCCA]
		,src.[DaysFromConsultToCCA]
		,src.[DaysFromFirstContactToConsult]
		,src.[DaysFromScheduledtoConsult]
		,src.[DaysToCCAFromFrstContact]
		,src.[DaysToCloseFromConsult]
		,src.[DaysToConvertFromConsult]
		,src.[DaystoConvertFromFirstContact]
		,src.[DID]
		,src.[DIDNumber]
		,src.[Finance]
		,src.[FirstContactDate]
		,src.[Gender]
		,src.[HasOptedOutOfEmail]
		,src.[Iam]
		,src.[IsConverted]
		,src.[LeadScore]
		,src.[LeadURLCampaign]
		,src.[LeadURLMedium]
		,src.[LeadURLSource]
		,src.[LeadURLTerm]
		,src.[LeadSource]
		,src.[OwnerID]
		,src.[PatientID]
		,src.[PCSTerritory]
		,src.[PCSTerritoryAgent]
		,src.[PrimaryGoal]
		,src.[ProspectID]
		,src.[ProspectStatus]
		,src.[RecordType]
		,src.[SmileVisualization]
		,src.[SmileView]
		,src.[State]
		,src.[Status]
		,src.[TestLead]
		,src.[ZIP]
		,src.[LeadRegion]
		,src.[HasOptedOutOfMobile]
		,src.[SecRegion]

	from #TempDimLead src
	where not exists (select dst.SKLead from DW.DimLead dst where dst.SKLead = src.SKLead)
	option (label = 'DW.LoadDimLead_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimLead_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
