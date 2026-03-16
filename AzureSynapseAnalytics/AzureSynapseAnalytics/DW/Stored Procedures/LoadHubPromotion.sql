CREATE PROC [DW].[LoadHubPromotion] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
	
	declare	@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime = getdate()

	if not exists (
		select *
		from DW.HubPromotion
		where SKPromotion = -1
	)
	begin
		set identity_insert DW.HubPromotion on
		begin try
			insert into DW.HubPromotion (
					SKPromotion
				,	KeyPromotion
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	-1
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DW.HubPromotion off;
			throw
		end catch
		set identity_insert DW.HubPromotion off
	end

	insert into DW.HubPromotion (
			KeyPromotion
		,	DWBatchID
		,	SourceSystemCode
		,	InsertDateTime
	)
	select	t.KeyPromotion
		,	@BatchID
		,	t.SourceSystemCode
		,	@dt 
	from (
		select top (1) with ties
				KeyPromotion
			,	SourceSystemCode
		from (
			select	id as KeyPromotion
				,	'Promotion' as SourceSystemCode
			from srcSFDC.Apttus_Config2__Incentive__c where id is not null
			UNION ALL
			Select distinct id as KeyPromotion
			,	'Promotion' as SourceSystemCode
			from SrcSFDC.[Apttus_Config2__Order__c] where id is not null
			UNION ALL
			select	Incentiveid as KeyPromotion
				,	'Promotion' as SourceSystemCode
			from Custom.DimPromotion where Incentiveid is not null
		) t
		order by row_number() over (partition by KeyPromotion order by SourceSystemCode)
	) t
	where not exists (
				select *
				from DW.HubPromotion h
				where h.KeyPromotion = t.KeyPromotion
		    )
	option (label = 'DW.LoadHubPromotion');

	exec CTRL.GetLastRowCount @Label = 'DW.LoadHubPromotion', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end
