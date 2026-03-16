CREATE PROC [DWIRIS].[LoadHubSalesContract] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
BEGIN
	
	declare 
			@RowsInserted int = 0,
			@RowsUpdated  int = 0,
			@dt datetime=getdate()

	--check for Unknow element
	
	if not exists (
		select *
		from DWIRIS.HubSalesContract
		where [SKSalesContract] = -1
	)
	begin
		set identity_insert DWIRIS.HubSalesContract on
		begin try
			insert into DWIRIS.HubSalesContract (
					[SKSalesContract]
				,	[KeySalesContract]
				,	DWBatchID
				,	SourceSystemCode
				,	InsertDateTime
			)
			values (
					-1
				,	'N/A'
				,	-1
				,	'N/A'
				,	@dt
			)
		end try
		begin catch
			set identity_insert DWIRIS.HubSalesContract off;
			throw
		end catch
		set identity_insert DWIRIS.HubSalesContract off
	end   --if statement

	   
		
	-- Pull all business keys to temp table 

	if object_id('tempdb..#TempHubSalesContract') is not null
		drop table #TempHubSalesContract
		
	create table #TempHubSalesContract
		(
			SalesContractID nchar(18), 
			SourceSystemCode varchar(10)
		)
		with (distribution = round_robin, heap) 
	
	declare @TypeId nchar(18)
	select  @TypeId=ID from [SrcSFDC].[RecordType] where [Name]='iTero Contracts'

	/* List of Record types included */

--0120H000001J6QaQAK	APAC iTero
--0120H000001QT9eQAG	EU Scanner
--0120H000001J6QXQA0	iTero Contracts
--0120H000001J6RIQA0	EU Lab
--0120H000000yUddQAE	LATAM Scanner
--012i00000019r6NAAQ	Scanner
--0120H000000u011QAA	APAC iTero – Distributor End User
--0120H000001QTSDQA4	EU iTero


	insert into #TempHubSalesContract (SalesContractID, SourceSystemCode)
	select 
		 [ID] as SalesContractID, 'SFDC' as SourceSystemCode 
	from [SrcSFDC].[Case] c 
	where RecordTypeID in ('0120H000001UWYrQAO','0120H000001J6QXQA0')
	UNION ALL
	select 
		 [ID] as SalesContractID, 'SFDC' as SourceSystemCode 
	from [SrcSFDC].[Opportunity] c 
	where 
		RecordTypeID in ('0120H000000yUddQAE','0120H000001J6QaQAK','0120H000001QT9eQAG','012i00000019r6NAAQ','0120H000000u011QAA'	
						 /*'0120H000001J6QaQAK','0120H000001QT9eQAG', '0120H000001J6QXQA0','0120H000001J6RIQA0',
						 '0120H000000yUddQAE','012i00000019r6NAAQ','0120H000000u011QAA','0120H000001QTSDQA4'*/
						 )
		/*and c.Id not in (select o.Id FROM SrcSFDC.[Case] c
							left join SrcSFDC.Opportunity o 
								on c.Opportunity__c = o.Id
						where o.Id is not null)*/

	
	--insert new keys to hub
	insert into DWIRIS.HubSalesContract
	(
		[KeySalesContract],
		[DWBatchID],
		[SourceSystemCode],
		[InsertDateTime]
	)
	select SalesContractId, @BatchID, SourceSystemCode, @dt from #TempHubSalesContract where SalesContractID not in (select KeySalesContract from DWIRIS.HubSalesContract)
	option (label = 'DWIRIS.LoadHubSalesContract');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadHubSalesContract', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END