CREATE PROC [DW].[LoadDimAccountSCD] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set nocount on
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id ('DW.DimAccountSCDNew', 'U') is not null
		drop table DW.DimAccountSCDNew

	create table DW.DimAccountSCDNew with (distribution = replicate, heap) as 
	with AccountHistory as (
		select	hub.SKAccount							as SKAccount
			,	hub.KeyAccount							as KeyAccount
			,	isnull(ch.ADLSBatchID, c.ADLSBatchID)	as ADLSBatchID	
			,	isnull(ch.ADLSTimestamp, c.ADLSTimestamp)	as ADLSTimestamp
			,	isnull(ch.LZBatchID, c.LZBatchID)		as LZBatchID	
			,	isnull(ch.StartDate, '1900-01-01')		as StartDate
			,   isnull(ch.EndDate, '2099-01-01')		as EndDate
			,	case when ch.ParentId is null or ch.Account_Status__c = 'NO_HISTORY'
					then convert(nvarchar(255), c.Account_Status__c)
					else convert(nvarchar(255), ch.Account_Status__c)
				end										as AccountStatus
			,	case when ch.ParentId is null or ch.ShippingCountryCode = 'NO_HISTORY'
					then convert(nvarchar(10), c.ShippingCountryCode)
					else convert(nvarchar(10), ch.ShippingCountryCode)
				end										as ShippingCountryCode
			,	case when ch.ParentId is null or ch.Group_Accounts__c = 'NO_HISTORY'
					then convert(nchar(18), c.Group_Accounts__c)
					else convert(nchar(18), ch.Group_Accounts__c)
				end										as GroupAccounts
			,	case when ch.ParentId is null or ch.Type = 'NO_HISTORY'
					then convert(nvarchar(40), c.Type)
					else convert(nvarchar(40), ch.Type)
				end										as Type
			,	case when ch.ParentId is null or ch.Account_Sub_Type__c = 'NO_HISTORY'
					then convert(nvarchar(255), c.Account_Sub_Type__c)
					else convert(nvarchar(255), ch.Account_Sub_Type__c)
				end										as AccountSubType
			,	case when ch.ParentId is null or ch.Customer_Group__c = 'NO_HISTORY'
					then convert(nvarchar(255), c.Customer_Group__c)
					else convert(nvarchar(255), ch.Customer_Group__c)
				end										as CustomerGroup
			,	case when ch.ParentId is null or ch.Account_Segmentation__c = 'NO_HISTORY'
					then convert(nvarchar(510), c.Account_Segmentation__c)
					else convert(nvarchar(510), ch.Account_Segmentation__c)
				end										as AccountSegmentation
			,	convert(nvarchar(256), gh.Country)		as ShippingCountry
			,	convert(nvarchar(256), gh.CountryGroup)	as ShippingCountryGroup
			,	convert(nvarchar(256), gh.RegionPC)		as ShippingRegionPC
			,	convert(nvarchar(256), gh.RegionGroup)	as ShippingRegionGroup
			,	convert(nvarchar(256), gh.GlobalRegion)	as ShippingGlobalRegion
		from SrcSFDC.Account c
		inner join DW.HubAccount hub on hub.KeyAccount = c.Id
		left join SrcSFDC.AccountHistoryFlattened ch on c.Id = ch.ParentId
		left join Custom.GeographyHierarchy gh on gh.CountryCode =	case when ch.ParentId is null or ch.ShippingCountryCode = 'NO_HISTORY'
															then c.ShippingCountryCode
															else ch.ShippingCountryCode
														end
	)
	select	SKAccount
		,	KeyAccount
		,	ADLSBatchID	
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID as DWBatchID
		,	StartDate as StartDateSCD
		,	EndDate as EndDateSCD
		,	AccountStatus
		,	ShippingCountryCode
		,	GroupAccounts
		,	Type
		,	AccountSubType
		,	CustomerGroup
		,	AccountSegmentation
		,	ShippingCountry
		,	ShippingCountryGroup
		,	ShippingRegionPC
		,	ShippingRegionGroup
		,	ShippingGlobalRegion
	from AccountHistory

	if object_id ('DW.DimAccountSCD', 'U') is not null
	begin
		if object_id ('DW.DimAccountSCDPrevious', 'U') is not null
			drop table DW.DimAccountSCDPrevious

		rename object DW.DimAccountSCD to DimAccountSCDPrevious
		rename object DW.DimAccountSCDNew to DimAccountSCD
		drop table DW.DimAccountSCDPrevious
	end
	else
	begin
		rename object DW.DimAccountSCDNew to DimAccountSCD
	end

	alter table DW.DimAccountSCD add constraint PK_DimAccountSCD primary key nonclustered (SKAccount, StartDateSCD) not enforced

	select @RowsInserted = count(*) 
	from DW.DimAccountSCD

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated 

end

