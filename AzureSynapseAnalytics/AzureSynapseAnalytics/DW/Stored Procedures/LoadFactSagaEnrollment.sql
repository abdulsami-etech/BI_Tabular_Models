CREATE PROC [DW].[LoadFactSagaEnrollment] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,	@IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	if object_id('DW.Temp_FactSagaEnrollment','U') is not null
		drop table DW.Temp_FactSagaEnrollment

	CREATE TABLE [DW].[Temp_FactSagaEnrollment]
(
	[LZBatchID] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NULL,
	[ID] [nchar](18) NOT NULL,
	[SKAccountSoldTo] [int] NULL,
	[SoldToAccountNumber] [nvarchar](40) NULL,
	[ContractNumber] [nvarchar](255) NULL,
	[IsActive] [bit] NULL,
	[CreatedDate] [datetime2](7) NOT NULL,
	[StartDate] [datetime2](7) NULL,
	[EligibilityStartDate] [datetime2](7) NULL,
	[EndDate] [datetime2](7) NULL,
	[EnrollmentType] [nvarchar](255) NULL,
	[PreEnrollmentAllowed] [varchar](5) NULL,
	[AllowableAligners] [decimal](18, 0) NULL,
	[AlignersUsed] [decimal](18, 0) NULL,
	[AlignersLeft] [decimal](18, 2) NULL,
	[AccountPricingGroupTreatLocCountry] [nvarchar](1300) NULL,
	[AccountPricingGroupTreatLoc] [nvarchar](1300) NULL,
	[SecRegion] [varchar](10) NULL,
	[SoldToAccountType] [nvarchar](40) NULL,
	[SoldToAccountSubType] [nvarchar](255) NULL
)
WITH
(
	DISTRIBUTION = ROUND_ROBIN,
	CLUSTERED COLUMNSTORE INDEX
	
)
ALTER TABLE [DW].[Temp_FactSagaEnrollment] ADD CONSTRAINT PK_Temp_FactSagaEnrollment PRIMARY KEY NONCLUSTERED ([ID]) NOT ENFORCED

	INSERT INTO [DW].[Temp_FactSagaEnrollment]
	(
	   [ADLSBatchID]
      ,[ADLSTimestamp]
      ,[LZBatchID]
      ,[DWBatchID]
	  ,[DWHash]
	  ,[ID] 
	  ,[SKAccountSoldTo] 
	  ,[SoldToAccountNumber]
	  ,[ContractNumber]
	  ,[IsActive] 
	  ,[CreatedDate] 
	  ,[StartDate]
	  ,[EligibilityStartDate]
	  ,[EndDate]
	  ,[EnrollmentType] 
	  ,[PreEnrollmentAllowed]
	  ,[AllowableAligners]
	  ,[AlignersUsed] 
	  ,[AlignersLeft] 
	  ,[AccountPricingGroupTreatLocCountry] 
	  ,[AccountPricingGroupTreatLoc]
	  ,[SecRegion] 
	  ,[SoldToAccountType]
	  ,[SoldToAccountSubType] 
	  )
	select	
					a.ADLSBatchID								as ADLSBatchID
			  ,		a.ADLSTimestamp								as ADLSTimestamp
			  ,		a.LZBatchID									as LZBatchID
			  ,     @BatchID									as DWBatchID
			  ,		convert(char(40), '')						as DWHash
			  ,		a.[ID]										as ID		
			  ,		hubSoldto.SKAccount							as SKAccountSoldTo 
			  ,		SoldToAct.AccountNumber						as SoldToAccountNumber 
			  ,		a.Contract_Number__c						as [ContractNumber]
			  ,		a.Apttus_Config2__Active__c					as [IsActive]
			  ,		a.CreatedDate								as [CreatedDate]
			  ,		a.Apttus_Config2__StartDate__c				as [StartDate]
			  ,		a.Apttus_Config2__EligibilityStartDate__c	as [EligibilityStartDate]
			  ,		a.Apttus_Config2__EndDate__c				as [EndDate]
			  ,		a.Apttus_Config2__EnrollmentType__c			as [EnrollmentType]
			  ,		a.Pre_Enrollment_Allowed__c					as [PreEnrollmentAllowed]
			  ,		a.Allowable_Aligners__c						as [AllowableAligners]
			  ,		a.Aligners_Used__c							as [AlignersUsed]
			  ,		a.Aligners_Left__c							as [AlignersLeft]
			  ,		a.Account_Pricing_Group_Tremt_Loc_Country__c as [AccountPricingGroupTreatLocCountry] 
			  ,		a.Account_Pricing_Group_Tremt_Location__c	as [AccountPricingGroupTreatLoc] 
			  ,		SoldtoAct.SecRegion							as SecRegion
			  ,		Soldtoact.AccountType						as SoldToAccountType 
			  ,		Soldtoact.SubType							as SoldToAccountSubType 
		from [SrcSFDC].[Apttus_Config2__IncentiveLoyaltyEnrollment__c] a
		left join DW.HubAccount hubSoldto on a.Apttus_Config2__AccountId__c = hubsoldTo.KeyAccount
		left join DW.DimAccount Soldtoact on Soldtoact.SKAccount = hubsoldto.SKAccount		
		where loyalty_code__C ='SAGA' 
	and (a.ADLSTimestamp >= @LastSuccessfullDWTimestamp or @IsFullLoad=1)
	


	--update HASH 
	update DW.Temp_FactSagaEnrollment set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				isnull(convert(nvarchar, ID), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SKAccountSoldTo), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SoldToAccountNumber), N'N/A')
				+ N'|' + isnull(convert(nvarchar, ContractNumber), N'N/A')
				+ N'|' + isnull(convert(nvarchar, IsActive), N'N/A')
				+ N'|' + isnull(convert(nvarchar, CreatedDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, StartDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, EligibilityStartDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, EndDate), N'N/A')
				+ N'|' + isnull(convert(nvarchar, EnrollmentType), N'N/A')
				+ N'|' + isnull(convert(nvarchar, PreEnrollmentAllowed), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AllowableAligners), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AlignersUsed), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AlignersLeft), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AccountPricingGroupTreatLocCountry), N'N/A')
				+ N'|' + isnull(convert(nvarchar, AccountPricingGroupTreatLoc), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SecRegion), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SoldToAccountType), N'N/A')
				+ N'|' + isnull(convert(nvarchar, SoldToAccountSubType), N'N/A')
				)
			,2)
	if @IsFullLoad = 0
	begin
	update DW.FactSagaEnrollment
		set	[ADLSBatchID] = src.[ADLSBatchID]
      ,[ADLSTimestamp] = src.[ADLSTimestamp]
      ,[LZBatchID]	= src.[ADLSBatchID]
      ,[DWBatchID]	= src.[DWBatchID]
      ,[DWHash]	= src.[DWHash]
      ,[SKAccountSoldTo]=src.[SKAccountSoldTo]
	  ,[SoldToAccountNumber]=src.[SoldToAccountNumber]
	  ,[ContractNumber]=src.[ContractNumber]
	  ,[IsActive]=src.[IsActive]
	  ,[CreatedDate]=src.[CreatedDate]
	  ,[StartDate]=src.[StartDate]
	  ,[EligibilityStartDate]=src.[EligibilityStartDate]
	  ,[EndDate]=src.[EndDate]
	  ,[EnrollmentType]=src.[EnrollmentType]
	  ,[PreEnrollmentAllowed]=src.[PreEnrollmentAllowed]
	  ,[AllowableAligners]=src.[AllowableAligners]
	  ,[AlignersUsed]=src.[AlignersUsed]
	  ,[AlignersLeft]=src.[AlignersLeft]
	  ,[AccountPricingGroupTreatLocCountry]=src.[AccountPricingGroupTreatLocCountry]
	  ,[AccountPricingGroupTreatLoc]=src.[AccountPricingGroupTreatLoc]
	  ,[SecRegion]=src.[SecRegion]
	  ,[SoldToAccountType]=src.[SoldToAccountType]
	  ,[SoldToAccountSubType]=src.[SoldToAccountSubType]
	  from DW.Temp_FactSagaEnrollment src
		where DW.FactSagaEnrollment.ID = src.ID 
			and DW.FactSagaEnrollment.DWHash != src.DWHash
		option (label = 'DW.LoadFactSagaEnrollment_Update');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactSagaEnrollment_Update', @rc = @RowsUpdated out

	insert into DW.FactSagaEnrollment (
	  [ADLSBatchID]
	  ,[ADLSTimestamp]
	  ,[LZBatchID]
	  ,[DWBatchID]
	  ,[DWHash]
	  ,[ID]
	  ,[SKAccountSoldTo]
	  ,[SoldToAccountNumber]
	  ,[ContractNumber]
	  ,[IsActive]
	  ,[CreatedDate]
	  ,[StartDate]
	  ,[EligibilityStartDate]
	  ,[EndDate]
	  ,[EnrollmentType]
	  ,[PreEnrollmentAllowed]
	  ,[AllowableAligners]
	  ,[AlignersUsed]
	  ,[AlignersLeft]
	  ,[AccountPricingGroupTreatLocCountry]
	  ,[AccountPricingGroupTreatLoc]
	  ,[SecRegion]
	  ,[SoldToAccountType]
	  ,[SoldToAccountSubType]

	  )
		select	 
	  [ADLSBatchID]
	  ,[ADLSTimestamp]
	  ,[LZBatchID]
	  ,[DWBatchID]
	  ,[DWHash]
	  ,[ID]
	  ,[SKAccountSoldTo]
	  ,[SoldToAccountNumber]
	  ,[ContractNumber]
	  ,[IsActive]
	  ,[CreatedDate]
	  ,[StartDate]
	  ,[EligibilityStartDate]
	  ,[EndDate]
	  ,[EnrollmentType]
	  ,[PreEnrollmentAllowed]
	  ,[AllowableAligners]
	  ,[AlignersUsed]
	  ,[AlignersLeft]
	  ,[AccountPricingGroupTreatLocCountry]
	  ,[AccountPricingGroupTreatLoc]
	  ,[SecRegion]
	  ,[SoldToAccountType]
	  ,[SoldToAccountSubType]
		from DW.Temp_FactSagaEnrollment src
		where not exists (select dst.ID from DW.FactSagaEnrollment dst where dst.ID = src.ID )
		option (label = 'DW.LoadFactSagaEnrollment_Insert');

		exec CTRL.GetLastRowCount @Label = 'DW.LoadFactSagaEnrollment_Insert', @rc = @RowsInserted out

		if object_id ('DW.Temp_FactSagaEnrollment', 'U') is not null
		drop table DW.Temp_FactSagaEnrollment
	end
	else
	begin --full load
		if object_id ('DW.FactSagaEnrollmentPrevious', 'U') is not null
			drop table DW.FactSagaEnrollmentPrevious

		rename object DW.FactSagaEnrollment to FactSagaEnrollmentPrevious
		rename object DW.Temp_FactSagaEnrollment to FactSagaEnrollment

		if object_id ('DW.FactSagaEnrollmentPrevious', 'U') is not null
		drop table DW.FactSagaEnrollmentPrevious
		rename object DW.PK_Temp_FactSagaEnrollment to PK_FactSagaEnrollment
		
		select @RowsInserted = count(*)
		from DW.FactSagaEnrollment

	end

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
