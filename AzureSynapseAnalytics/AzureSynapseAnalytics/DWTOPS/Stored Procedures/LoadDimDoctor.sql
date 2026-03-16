CREATE PROC [DWTOPS].[LoadDimDoctor] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0),@IsForceFullLoad [bit] AS
begin
	set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0
		,   @IsFullLoad		bit = 0

	set @IsFullLoad = isnull(@IsForceFullLoad, 0)

	--Set last sucessful DW LoadTime
	select @LastSuccessfullDWTimestamp=isnull(max(ADLSTimestamp), '19000101') from DWTOPS.DimDoctor


if object_id('DWTOPS.Temp_DimDoctor','U') is not null
	drop table DWTOPS.Temp_DimDoctor


CREATE TABLE [DWTOPS].[Temp_DimDoctor]
(
	[SKDoctor] [int] NOT NULL,
	[ADLSBatchID] [int] NOT NULL,
	[ADLSTimestamp] [datetime2](0) NOT NULL,
	[LZBatchID] [int] NOT NULL,
	[DWBatchID] [int] NOT NULL,
	[DWHash] [char](40) NOT NULL,
	[KeyDoctor] [nvarchar](80) NOT NULL,
	[ClinicianID] [nvarchar](50) NULL,
	[DoctorFirstName] [nvarchar](50) NULL,
	[DoctorLastName] [nvarchar](50) NULL,
	[DoctorFullName] [nvarchar](101) NULL,
	[DoctorSource] [varchar](80) NULL,
	[DoctorCertLevel] [int] NULL,
	[DoctorCalculatedLevel] [int] NULL,
	[DoctorCalculatedLevelFlag] [varchar](30) NULL,
	[DoctorJDETeam] [int] NULL,
	[DoctorSkillLevel] [int] NULL,
	[DoctorRegionMES] [nvarchar](100) NULL,
	[SKCountry] [int]  NULL
)
WITH
(
	DISTRIBUTION = REPLICATE,
	CLUSTERED INDEX
	(
		[SKDoctor] ASC
	)
)



INSERT INTO [DWTOPS].[Temp_DimDoctor]
           ([SKDoctor]
           ,[ADLSBatchID]
           ,[ADLSTimestamp]
           ,[LZBatchID]
           ,[DWBatchID]
           ,[DWHash]
           ,[KeyDoctor]
           ,[ClinicianID]
           ,[DoctorFirstName]
           ,[DoctorLastName]
           ,[DoctorFullName]
           ,[DoctorSource]
           ,[DoctorCertLevel]
           ,[DoctorCalculatedLevel]
           ,[DoctorCalculatedLevelFlag]
           ,[DoctorJDETeam]
           ,[DoctorSkillLevel]
		   ,[DoctorRegionMES]
		   ,[SKCountry])
	select	h.SKDoctor							as SKDoctor
		,	t.ADLSBatchID						as ADLSBatchID
		,	t.ADLSTimestamp						as ADLSTimestamp
		,	t.LZBatchID							as LZBatchID
		,   @BatchID                            as DWBatchID
		,	convert(char(40), '')				as DWHash
		,	t.DoctorID							as KeyDoctor
		,	t.ClinicianID						as ClinicianID
		,	convert(nvarchar(50), t.FirstName)	as DoctorFirstName
		,	convert(nvarchar(50), t.LastName)	as DoctorLastName
		,	convert(nvarchar(1010), isnull(t.[FirstName] + ' ', '') + isnull(t.[LastName], '')) as DoctorFullName
		,	t.[Source]							as DoctorSource
		,	convert(int, t.CertLevel)			as DoctorCertLevel
		,	convert(int, t.CalculatedLevel)		as DoctorCalculatedLevel
		,	case t.CalculatedLevelFlag
				when 'Y' then 'Doctor Level Is Calculated'
				when 'N' then 'Doctor Level Is Not Calculated'
			else 'NA' end						as DoctorCalculatedLevelFlag
		,	convert(int, t.JDETeam)				as DoctorJDETeam
		,	convert(int, t.SkillLevel)			as DoctorSkillLevel
		,	r.[atr_name]						as DoctorRegionMES
		,  ISNULL(c.[SKCountry],-1)				as SKCountry

	from (Select *,Row_number()over(partition by DoctorID order by last_modified_time_u desc ) as LatestRow 
            from SrcMESCorp.DC_at_DoctorInformation) t
	inner join DWTOPS.HubDoctor h on h.KeyDoctor = t.DoctorID
	left  join [DW].[DimAccount] a on a.[AccountNumber] = t.DoctorID
	left  join [DW].[DimCountry] c on c.[CountryCode] = a.[ShippingCountryCode]
	left  join (Select *,ROW_Number()over(partition by JDETeamNumber_S order by last_modified_time desc) as latest 
	from [SrcMESCorp].[AT_at_Regions]) r on r.[JDETeamNumber_S] = t.JDETeam and r.latest=1

	where t.DoctorID is not null and LatestRow=1
		and ( t.ADLSTimestamp >= @LastSuccessfullDWTimestamp or  @IsFullLoad=1)

	update  [DWTOPS].[Temp_DimDoctor]
		set DWHash =	convert(char(40),
							hashbytes('SHA1', 
										isnull(ClinicianID, 'N/A') 
								+ '|' + isnull(DoctorFirstName, 'N/A') 
								+ '|' + isnull(DoctorLastName, 'N/A') 
								+ '|' + isnull(DoctorFullName, 'N/A') 
								+ '|' + isnull(DoctorSource, 'N/A') 
								+ '|' + isnull(convert(varchar, DoctorCertLevel), 'N/A') 
								+ '|' + isnull(convert(varchar, DoctorCalculatedLevel), 'N/A') 
								+ '|' + isnull(DoctorCalculatedLevelFlag, 'N/A') 
								+ '|' + isnull(convert(varchar, DoctorJDETeam), 'N/A') 
								+ '|' + isnull(convert(varchar, DoctorSkillLevel), 'N/A')
								+ '|' + isnull(convert(varchar, DoctorRegionMES), 'N/A')
								+ '|' + isnull(convert(varchar, SKCountry), 'N/A')
							)
							, 2
						)

	if not exists (select * from DWTOPS.Temp_DimDoctor where SKDoctor = -1)
	begin
		declare @Hash char(40) = convert(char(40), hashbytes('SHA1', N'N/A'), 2)

		insert into DWTOPS.Temp_DimDoctor (
				SKDoctor
			,	ADLSBatchID
			,	ADLSTimestamp
			,	LZBatchID
			,	DWBatchID
			,	DWHash
			,	KeyDoctor
			,	ClinicianID
			,	DoctorFirstName
			,	DoctorLastName
			,	DoctorFullName
			,	DoctorSource
			,	DoctorCertLevel
			,	DoctorCalculatedLevel
			,	DoctorCalculatedLevelFlag
			,	DoctorJDETeam
			,	DoctorSkillLevel
			,   DoctorRegionMES
		    ,   SKCountry
		)
		values (
				-1
			,	-1
			,	'19000101'
			,	-1
			,	@BatchID
			,	@Hash
			,	N'N/A'
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,	null
			,   null
			,   null
		)
	end



if @IsFullLoad = 0
	begin

	update DWTOPS.DimDoctor
		set	ADLSBatchID = src.ADLSBatchID
		,	ADLSTimestamp = src.ADLSTimestamp
		,	LZBatchID = src.LZBatchID
		,	DWBatchID = @BatchID
		,	DWHash = src.DWHash
		,	ClinicianID = src.ClinicianID
		,	DoctorFirstName = src.DoctorFirstName
		,	DoctorLastName = src.DoctorLastName
		,	DoctorFullName = src.DoctorFullName
		,	DoctorSource = src.DoctorSource
		,	DoctorCertLevel = src.DoctorCertLevel
		,	DoctorCalculatedLevel = src.DoctorCalculatedLevel
		,	DoctorCalculatedLevelFlag = src.DoctorCalculatedLevelFlag
		,	DoctorJDETeam = src.DoctorJDETeam
		,	DoctorSkillLevel = src.DoctorSkillLevel
		,	DoctorRegionMES = src.DoctorRegionMES
		,	SKCountry = src.SKCountry
	from DWTOPS.Temp_DimDoctor src
	where DWTOPS.DimDoctor.SKDoctor = src.SKDoctor
		and DWTOPS.DimDoctor.DWHash != src.DWHash

	option (label = 'DWTOPS.LoadDimDoctor_Update');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimDoctor_Update', @rc = @RowsUpdated out

	insert into DWTOPS.DimDoctor (
			SKDoctor
		,	ADLSBatchID
		,	ADLSTimestamp
		,	LZBatchID
		,	DWBatchID
		,	DWHash
		,	KeyDoctor
		,	ClinicianID
		,	DoctorFirstName
		,	DoctorLastName
		,	DoctorFullName
		,	DoctorSource
		,	DoctorCertLevel
		,	DoctorCalculatedLevel
		,	DoctorCalculatedLevelFlag
		,	DoctorJDETeam
		,	DoctorSkillLevel
		,   DoctorRegionMES
		,   SKCountry
	)
	select	src.SKDoctor
		,	src.ADLSBatchID
		,	src.ADLSTimestamp
		,	src.LZBatchID
		,	@BatchID
		,	src.DWHash
		,	src.KeyDoctor
		,	src.ClinicianID
		,	src.DoctorFirstName
		,	src.DoctorLastName
		,	src.DoctorFullName
		,	src.DoctorSource
		,	src.DoctorCertLevel
		,	src.DoctorCalculatedLevel
		,	src.DoctorCalculatedLevelFlag
		,	src.DoctorJDETeam
		,	src.DoctorSkillLevel
		,	src.DoctorRegionMES
		,   src.SKCountry
	from DWTOPS.Temp_DimDoctor  src
	where  not exists(select * from DWTOPS.DimDoctor dst where dst.SKDoctor = src.SKDoctor)
	option (label = 'DWTOPS.LoadDimDoctor_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadDimDoctor_Insert', @rc = @RowsInserted out

		if object_id ('DWTOPS.Temp_DimDoctor', 'U') is not null
		drop table DWTOPS.Temp_DimDoctor

	end
	  else  --- Full load =1 begin
	    begin 
			if object_id ('DWTOPS.DimDoctorPrevious', 'U') is not null
			drop table DWTOPS.DimDoctorPrevious

		rename object DWTOPS.DimDoctor to DimDoctorPrevious
		rename object DWTOPS.Temp_DimDoctor to DimDoctor
		
		if object_id ('DWTOPS.DimDoctorPrevious', 'U') is not null
		drop table DWTOPS.DimDoctorPrevious

		select @RowsInserted = count(*)
		from DWTOPS.DimDoctor


		end



	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
end