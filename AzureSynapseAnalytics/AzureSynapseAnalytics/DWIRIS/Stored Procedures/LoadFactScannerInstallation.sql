CREATE PROC [DWIRIS].[LoadFactScannerInstallation] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	set xact_abort on

	declare @RowsInserted		int = 0
		,	@RowsInsertedTotal	int = 0
		,	@RowsUpdated		int = 0
		,	@today				date
		,	@todayInt			int

	set @today = getdate()
	set @todayInt = cast(convert(varchar(8), @today, 112) as int)

	if object_id('tempdb..#TempFactScannerInstallation') is not null
		drop table #TempFactScannerInstallation

	create table #TempFactScannerInstallation with (distribution = round_robin, heap) as 
	select	dt.SKDate					as SKDate
		,	a.ADLSBatchID				as ADLSBatchID
		,	a.ADLSTimestamp				as ADLSTimestamp
		,	a.LZBatchID					as LZBatchID
		,	has.SKAsset					as SKAsset
		,	isnull(ha.SKAccount, -1)	as SKAccount
	from SrcSFDC.Asset a
	inner join DWIRIS.HubAsset has on has.KeyAsset = a.SerialNumber
	left join DW.HubAccount ha on ha.KeyAccount = a.AccountId
	inner join DW.DimDate dt on dt.KeyDate between convert(date, a.InstallDate) and isnull(convert(date, a.UsageEndDate), @today) 
	where a.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		and a.Asset_Type__c = 'SCANNER' 
		and isnull(a.SerialNumber, '') <> '' 
		and a.Status = 'Installed'
		and a.InstallDate is not null

	insert into #TempFactScannerInstallation (
			SKDate
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	SKAsset
		,	SKAccount
	)
	select	dt.SKDate					as SKDate
		,	s.ADLSBatchID				as ADLSBatchID
		,	s.ADLSTimestamp				as ADLSTimestamp
		,	s.LZBatchID					as LZBatchID
		,	has.SKAsset					as SKAsset
		,	isnull(ha.SKAccount, -1)	as SKAccount
	from SrcMAT.svc_EquipmentCard s
    inner join DWIRIS.HubAsset has on has.KeyAsset = s.SerialIdentifier
	left join SrcMAT.BusinessPartnerSalesforceLink bps on s.HolderBusinessPartnerID = bps.BusinessPartnerId
														and bps.RowStatusID <> 5
	left join (
		select	t.BusinessPartnerId
			,	a.Id
		from SrcMAT.BusinessPartnerSalesforceLink t
		left join SrcSFDC.Account a on a.Account_Number__c = t.SalesforceAccountNum
									and try_convert(int, a.MAT_ID__c) = t.BusinessPartnerId 
									and t.RowStatusID <> 5
		where a.Id is not null
	) a1 on a1.BusinessPartnerId = bps.BusinessPartnerId
	left join DW.HubAccount ha on ha.KeyAccount = a1.ID
	left join (
		select	t.ResourceSerialIdentifier
			,	t.DateCreated
			,	t.UsageEndDate
		from (
			select	res.ResourceSerialIdentifier
				,	DateCreated
				,	row_number() over (partition by res.ResourceSerialIdentifier order by res.DateCreated) as rn
				,	first_value(InvalidateDate) over (partition by res.ResourceSerialIdentifier order by res.DateCreated desc) as UsageEndDate
			from SrcMAT.Resources res
			where res.RowStatusID = 1
		) t
		where t.rn = 1
	) reg on reg.ResourceSerialIdentifier = s.SerialIdentifier
	inner join DW.DimDate dt on dt.KeyDate between convert(date, reg.DateCreated) and isnull(convert(date, reg.UsageEndDate), @today) 
	where s.ADLSTimestamp >= isnull(@LastSuccessfullDWTimestamp, '19000101')
		and s.SerialIdentifier not in (select SerialNumber from SrcSFDC.Asset)

	begin tran

	delete from DWIRIS.FactScannerInstallation
	where exists (
		select *
		from #TempFactScannerInstallation s
		where s.SKAsset = DWIRIS.FactScannerInstallation.SKAsset
	)
	option (Label = 'DWIRIS.FactScannerInstallation_Delete');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactScannerInstallation_Delete', @rc = @RowsUpdated out

	insert into DWIRIS.FactScannerInstallation (
			SKDate
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	SKAsset
		,	SKAccount
	)
	select	SKDate
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	@BatchID
		,	SKAsset
		,	SKAccount
	from #TempFactScannerInstallation
	option (label = 'DWIRIS.FactScannerInstallation_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactScannerInstallation_Insert', @rc = @RowsInserted out
	set @RowsInsertedTotal += @RowsInserted

	insert into DWIRIS.FactScannerInstallation (
			SKDate
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	SKAsset
		,	SKAccount
	)
	select	dt.SKDate
		,	a.ADLSBatchID
		,	a.ADLSTimestamp
		,	a.LZBatchID
		,	@BatchID
		,	has.SKAsset
		,	isnull(ha.SKAccount, -1)
	from SrcSFDC.Asset a
	inner join DWIRIS.HubAsset has on has.KeyAsset = a.SerialNumber
	left join DW.HubAccount ha on ha.KeyAccount = a.AccountId
	inner join (
		select	SKAsset
			,	max(SKDate) as LastSKDate
		from DWIRIS.FactScannerInstallation
		group by SKAsset
	) f on f.SKAsset = has.SKAsset
	inner join DW.DimDate dt on dt.SKDate > f.LastSKDate 
							and dt.SKDate <= isnull(cast(convert(varchar(8), a.UsageEndDate, 112) as int), @todayInt)
								
	option (label = 'DWIRIS.FactScannerInstallation_Insert_notchanged');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.FactScannerInstallation_Insert_notchanged', @rc = @RowsInserted out
	set @RowsInsertedTotal += @RowsInserted

	commit tran

	select @RowsInsertedTotal - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated
	
end

