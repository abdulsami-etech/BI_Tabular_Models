CREATE PROC [DWMyInvisalignApp].[LoadSatUser] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [int] AS
begin
	set xact_abort on


	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	Select @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)

	if object_id('tempdb..#TempSatUser') is not null
	drop table #TempSatUser


	create table #TempSatUser with (distribution = round_robin, heap) as 
		Select 
			hu.SKUser,
			s.ADLSBatchID						as ADLSBatchID,
			s.ADLSTimestamp					as ADLSTimestamp,
			s.LZBatchID						as LZBatchID,
			convert(char(40), '')				as DWHash,
            Continent ,
            SubContinent,
            Region     ,
            Country     ,
            City       ,
            Metro     
		FROM (
			Select TOP 1 WITH TIES
				s.user_pseudo_id,
				s.ADLSBatchID					as ADLSBatchID,
				s.ADLSTimestamp					as ADLSTimestamp,
				s.LZBatchID						as LZBatchID,
				s.event_timestamp               as UserTimestamp,
                JSON_VALUE(s.geo,'$.continent') as Continent,
                JSON_VALUE(s.geo,'$.country') as country,
                JSON_VALUE(s.geo,'$.sub_continent') as SubContinent,
                JSON_VALUE(s.geo,'$.region') as region,
                JSON_VALUE(s.geo,'$.city') as city,
                JSON_VALUE(s.geo,'$.metro') as metro
			from SrcGoogleBigQuery.MyInvisalignAppOther s
			where  s.event_name='session_start' and s.user_pseudo_id IS NOT NULL
			and (s.ADLSTimestamp>=@LastSuccessfullDWTimestamp OR @IsForceFullLoad=1)
			ORDER BY ROW_NUMBER() OVER (PARTITION BY s.user_pseudo_id ORDER BY s.event_timestamp DESC)
			) s
		JOIN DWMyInvisalignApp.HubUser hu on hu.KeyUser = s.user_pseudo_id



	update #TempSatUser set DWHash=
		convert(char(40),
			hashbytes('SHA1',
						ISNULL(convert(nvarchar,Continent),'')
					+'|'+ISNULL(convert(nvarchar,SubContinent),'')
					+'|'+ISNULL(convert(nvarchar,Region),'')
					+'|'+ISNULL(convert(nvarchar,Country),'')
					+'|'+ISNULL(convert(nvarchar,City),'')
					+'|'+ISNULL(convert(nvarchar,Metro),'')
				)
			,2)



	--   Create Unknow Element in case there is none
	if not exists (select * from DWMyInvisalignApp.SatUser where SKUser = -1)
	begin
		declare @Hash char(40) = ''
		insert into DWMyInvisalignApp.SatUser (
				SKUser,
				ADLSBatchID,
				ADLSTimestamp,
				LZBatchID,
				DWBatchID,
				DWHash,
                Continent   ,
                SubContinent,
                Region      ,
                Country     ,
                City        ,
                Metro  

		)
		Select
				-1 as SKUser,
				-1 as ADLSBatchID,
				'2000-01-01' as ADLSTimestamp,
				0 as LZBatchID,
				0 as DWBatchID,
				@Hash as DWHash,
			    NULL AS Continent   ,
                NULL AS SubContinent,
                NULL AS Region      ,
                NULL AS Country     ,
                NULL AS City        ,
                NULL AS Metro  
		
	end
	--  End  createing unknow element

	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update DWMyInvisalignApp.SatUser
		set
		    ADLSBatchID = src.ADLSBatchID,
			ADLSTimestamp = src.ADLSTimestamp,
			LZBatchID = src.LZBatchID,
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
            Continent = src.Continent   ,
            SubContinent = src.SubContinent,
            Region = src.Region      ,
            Country = src.Country     ,
            City = src.City        ,
            Metro = src.Metro  
	from #TempSatUser src
	where DWMyInvisalignApp.SatUser.SKUser = src.SKUser
		and DWMyInvisalignApp.SatUser.DWHash != src.DWHash
	option (label = 'DWMyInvisalignApp.LoadSatUser');
	
	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatUser', @rc = @RowsUpdated out


	--INSERT new rows
	INSERT DWMyInvisalignApp.SatUser (
		SKUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		DWBatchID,
		DWHash,
        Continent   ,
        SubContinent,
        Region      ,
        Country     ,
        City        ,
        Metro  
		)
	SELECT
		SKUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		@BatchID as DWBatchID,
		DWHash,
        Continent   ,
        SubContinent,
        Region      ,
        Country     ,
        City        ,
        Metro  
	from #TempSatUser src
	where not exists(
		select dst.SKUser
		from DWMyInvisalignApp.SatUser dst 
		where dst.SKUser = src.SKUser
	)
	option (label = 'DWMyInvisalignApp.LoadSatUser');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatUser', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

end --procedure