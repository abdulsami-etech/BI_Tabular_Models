CREATE PROC [DWIRIS].[LoadHubVirtualProduct] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknown element
	
	if not exists (
		select *
		from DWIRIS.HubVirtualProduct
		where [SKVirtualProduct] = -1
	)
	begin
		set identity_insert DWIRIS.HubVirtualProduct on
		begin try
			insert into DWIRIS.HubVirtualProduct (
					 [SKVirtualProduct]
					,[KeyVirtualProduct]
					,[DWBatchID]
					,[InsertDateTime]
			)
			values (
					-1
				,	-1
				,	-1
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubVirtualProduct off;
			throw
		end catch
		set identity_insert DWIRIS.HubVirtualProduct off
	end   --if statement

	   
		
	-- Pull all business keys to temp table from MAT and SFDC

	if object_id('tempdb..#TempHubVirtualProduct') is not null
		drop table #TempHubVirtualProduct
		
	create table #TempHubVirtualProduct
		(
			VirtualProductID int
		)
		with (distribution = round_robin, heap) 

	insert into #TempHubVirtualProduct (
		VirtualProductID
	)
	select vp.VirtualProductID as VirtualProductID
	from SrcMAT.svc_VirtualProduct vp

	--insert new keys to hub
	insert into DWIRIS.HubVirtualProduct
	(
		KeyVirtualProduct
	,	DWBatchID
	,	InsertDateTime
	)

	select 
	      src.VirtualProductID
		, @BatchID
		, @dt 
	from #TempHubVirtualProduct src
	where src.VirtualProductID not in (select dst.KeyVirtualProduct from DWIRIS.HubVirtualProduct dst)
	option (label = 'DWIRIS.LoadHubVirtualProduct');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubVirtualProduct', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end

