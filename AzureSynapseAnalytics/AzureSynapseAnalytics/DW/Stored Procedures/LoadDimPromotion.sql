CREATE PROC [DW].[LoadDimPromotion] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimPromotion') is not null
		drop table #TempDimPromotion

	create table #TempDimPromotion with (distribution = round_robin, heap) as 
	select	  ADLSBatchID
			, ADLSTimestamp
			, LZBatchID
			, DWBatchID
			, DWHash
			, SKPromotion
			, IncentiveID
			, IncentiveNumber
			, IncentiveCode 
			, IncentiveName
			, IncentiveGroup
			, SAPPricingCondition
			, PromotionStartDate
			, PromotionEndDate
			, PromotionRegion
			, datediff(day, PromotionStartDate, PromotionEndDate) + 1 as PromotionLengthDays
			, case 
				when datediff(day, PromotionStartDate, PromotionEndDate) + 1 <= 365
					then N'Less than 1 year'
				when datediff(day, PromotionStartDate, PromotionEndDate) + 1 between 366 and 30000
					then N'More than 1 year'
				when datediff(day, PromotionStartDate, PromotionEndDate) + 1 > 30000 
					then N'Ongoing Promo'
				END as PromotionLengthType
			, PromotionSubUseType
			, PromotionUseType
from
(
	select	promo.ADLSBatchID						as ADLSBatchID
		,	promo.ADLSTimestamp						as ADLSTimestamp
		,	promo.LZBatchID							as LZBatchID
		,	@BatchId								as DWBatchID
		,	convert(char(40), '')					as DWHash
		,	ho.SKPromotion							as SKPromotion
		,	cast(promo.id as nvarchar(50))									as IncentiveID
		,	cast(promo.Apttus_Config2__IncentiveNumber__c as nvarchar(50))	as IncentiveNumber
		,	cast(promo.Apttus_Config2__IncentiveCode__c as nvarchar(50))	as IncentiveCode 
		,	cast(promo.Name as nvarchar(80))								as IncentiveName		
		,	cast(promog.Name as nvarchar(80))								as IncentiveGroup
		,	cast(promog.SAP_Pricing_Condition__c as nvarchar(50))			as SAPPricingCondition
		,	cast(promo.Apttus_Config2__EffectiveDate__c as date)			as PromotionStartDate
		,	cast(promo.Apttus_Config2__ExpirationDate__c as date)			as PromotionEndDate
		,	cast(promo.Apttus_Config2__RegionScope__c as nvarchar(50))		as PromotionRegion
		,	cast(promo.Apttus_Config2__SubUseType__c as nvarchar(50))		as PromotionSubUseType
		,	cast(promo.Apttus_Config2__UseType__c as nvarchar(50))			as PromotionUseType
	from srcSFDC.Apttus_Config2__Incentive__c promo
	inner join DW.HubPromotion ho on ho.KeyPromotion = promo.id
	inner join srcSFDC.Apttus_Config2__IncentiveGroup__c promog on promo.Apttus_Config2__IncentiveGroupId__c = promog.Id
	UNION
	select	promo.ADLSBatchID						as ADLSBatchID
		,	promo.ADLSTimestamp						as ADLSTimestamp
		,	promo.LZBatchID							as LZBatchID
		,	promo.DWBatchID							as DWBatchID
		,	convert(char(40), '')					as DWHash
		,	ho.SKPromotion							as SKPromotion
		,	cast(promo.IncentiveID as nvarchar(50))			as IncentiveID
		,	cast(promo.IncentiveNumber as nvarchar(50))		as IncentiveNumber
		,	cast(promo.IncentiveCode as nvarchar(50))		as IncentiveCode 
		,	cast(promo.IncentiveName as nvarchar(80))		as IncentiveName		
		,	cast(promo.IncentiveGroup as nvarchar(80))		as IncentiveGroup
		,	cast(promo.SAPPricingCondition as nvarchar(50))	as SAPPricingCondition
		,	cast(promo.PromotionStartDate as date)			as PromotionStartDate
		,	cast(promo.PromotionEndDate as date)			as PromotionEndDate
		,	cast(promo.PromotionRegion as nvarchar(50))		as PromotionRegion
		,	cast(promo.PromotionSubUseType as nvarchar(50))	as PromotionSubUseType
		,	cast(promo.PromotionUseType as nvarchar(50))	as PromotionUseType
	from Custom.DimPromotion promo
	inner join DW.HubPromotion ho on ho.KeyPromotion = promo.Incentiveid
	where promo.IncentiveCode not in (select distinct Apttus_Config2__IncentiveCode__c from srcSFDC.Apttus_Config2__Incentive__c)
) a

	--where a.ADLSTimestamp >= (select isnull(max(ADLSTimestamp), '19000101') from DW.DimAccount)

	update #TempDimPromotion set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						  isnull(convert(nvarchar, IncentiveNumber), N'N/A')
				  + N'|' + isnull(convert(nvarchar, IncentiveCode), N'N/A')
				  + N'|' + isnull(convert(nvarchar, IncentiveName), N'N/A')
				  + N'|' + isnull(convert(nvarchar, IncentiveGroup), N'N/A')
				  + N'|' + isnull(convert(nvarchar, SAPPricingCondition), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionStartDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionEndDate), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionRegion), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionLengthDays), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionLengthType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionSubUseType), N'N/A')
				  + N'|' + isnull(convert(nvarchar, PromotionUseType), N'N/A')
				)
			, 2)


	update DW.DimPromotion
		set	ADLSBatchID				=			src.ADLSBatchID
		,	ADLSTimestamp			=			src.ADLSTimestamp
		,	LZBatchID				=			src.LZBatchID
		,	DWBatchID				=			src.DWBatchID
		,	DWHash					=			src.DWHash
		,	IncentiveID				=			src.IncentiveID
		,	IncentiveNumber			=			src.IncentiveNumber
		,	IncentiveCode			=			src.IncentiveCode 
		,	IncentiveName			=			src.IncentiveName
		,	IncentiveGroup			=			src.IncentiveGroup
		,	SAPPricingCondition		=			src.SAPPricingCondition
		,	PromotionStartDate		=			src.PromotionStartDate
		,	PromotionEndDate		=			src.PromotionEndDate
		,	PromotionRegion			=			src.PromotionRegion
		,	PromotionLengthDays		=			src.PromotionLengthDays
		,	PromotionLengthType		=			src.PromotionLengthType
		,	PromotionSubUseType		=			src.PromotionSubUseType
		,	PromotionUseType		=			src.PromotionUseType
	from #TempDimPromotion src
	where DW.DimPromotion.SKPromotion = src.SKPromotion
		and DW.DimPromotion.DWHash != src.DWHash
	option (label = 'DW.LoadDimPromotion_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimPromotion_Update', @rc = @RowsUpdated out

	insert into DW.DimPromotion (
			SKPromotion
		,	IncentiveID
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,   IncentiveNumber
		,   IncentiveCode 
		,   IncentiveName
		,   IncentiveGroup
		,   SAPPricingCondition
		,   PromotionStartDate
		,   PromotionEndDate
		,   PromotionRegion
		,   PromotionLengthDays
		,   PromotionLengthType
		,   PromotionSubUseType
		,   PromotionUseType

		
	)
	select	src.SKPromotion
		,	src.IncentiveID
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	src.DWBatchID
		,	src.DWHash
		,   src.IncentiveNumber
		,   src.IncentiveCode 
		,   src.IncentiveName
		,   src.IncentiveGroup
		,   src.SAPPricingCondition
		,   src.PromotionStartDate
		,   src.PromotionEndDate
		,   src.PromotionRegion
		,   src.PromotionLengthDays
		,   src.PromotionLengthType
		,   src.PromotionSubUseType
		,   src.PromotionUseType

	from #TempDimPromotion src
	where not exists(select SKPromotion from DW.DimPromotion dst where dst.SKPromotion = src.SKPromotion)
	option (label = 'DW.LoadDimPromotion_Insert');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadDimPromotion_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end



