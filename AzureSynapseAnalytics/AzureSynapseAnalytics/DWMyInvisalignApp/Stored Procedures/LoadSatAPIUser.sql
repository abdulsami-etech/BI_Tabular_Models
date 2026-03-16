CREATE PROC [DWMyInvisalignApp].[LoadSatAPIUser]
    @BatchID [int],
    @LastSuccessfullDWTimestamp [datetime2](0),
    @IsForceFullLoad [int] AS
BEGIN
	SET XACT_ABORT ON

	DECLARE @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	SELECT @IsForceFullLoad  = COALESCE(@IsForceFullLoad, 0)

	IF OBJECT_ID('TEMPDB..#UUIDsToLoad') IS NOT NULL
	DROP TABLE #UUIDsToLoad

    CREATE TABLE #UUIDsToLoad WITH (DISTRIBUTION = ROUND_ROBIN, HEAP) AS
        SELECT
            s.uuid
        FROM SrcAvro.UserProfileApi s
        WHERE  (s.ADLSTimestamp>=@LastSuccessfullDWTimestamp OR @IsForceFullLoad=1)
        GROUP BY s.uuid

	    UNION

	    SELECT u.uuid
        FROM SrcKafkaHeroku.user_profile_event u
        WHERE  (u.ADLSTimestamp>=@LastSuccessfullDWTimestamp OR @IsForceFullLoad=1)
        GROUP BY u.uuid


	IF OBJECT_ID('TEMPDB..#LeadHistory') IS NOT NULL
	DROP TABLE #LeadHistory


	CREATE TABLE #LeadHistory WITH (DISTRIBUTION = HASH(uuid), HEAP) AS
	SELECT
        s.uuid,
        MAX(s.ADLSBatchID) as ADLSBatchID	,
        MAX(s.ADLSTimestamp) as ADLSTimestamp	,
        MAX(s.LZBatchID) as LZBatchID		,
        MAX(s.lead_id) as lead_id         ,
        MAX(s.user_type) as user_type       ,
        MAX(s.remote_care_invite_status) as remote_care_invite_status ,
        MAX(s.remote_care_accept_terms) as remote_care_accept_terms ,
        MAX(TRY_CONVERT(datetime,LEFT(s.created_date,19))) as created_date    ,
        MAX(TRY_CONVERT(datetime,LEFT(s.updated_date,19))) as updated_date    ,
        MAX(CASE WHEN s.is_app_user=1 THEN 1 ELSE 0 END) as is_app_user,
        MAX(CASE WHEN s.is_demo=1 THEN 1 ELSE 0 END) as is_demo   ,
	    MAX(s.SequenceNumber) as SequenceNumber,
	       NULL AS _timestamp,
	    MAX(s.clin_id) as clin_id,
	    MAX(s.mailing_country) as mailing_country
    from SrcAvro.UserProfileApi s
	JOIN #UUIDsToLoad u on u.uuid=s.uuid
	/*Grouping data because of thousands of duplicated messages from eventHub*/
    GROUP BY s.uuid,
             convert(char(40),
                        hashbytes('SHA1',
                                  ISNULL(convert(nvarchar, lead_id), '')
                                      + '|' + ISNULL(convert(nvarchar, user_type), '')
                                      + '|' + ISNULL(convert(nvarchar, remote_care_invite_status), '')
                                      + '|' + ISNULL(convert(nvarchar, remote_care_accept_terms), '')
                                      + '|' + ISNULL(convert(nvarchar, created_date), '')
                                      + '|' + ISNULL(convert(nvarchar, updated_date), '')
                                      + '|' + ISNULL(convert(nvarchar, is_app_user), '')
                                      + '|' + ISNULL(convert(nvarchar, is_demo), '')
                                      + '|' + ISNULL(convert(nvarchar, clin_id), '')
                                      + '|' + ISNULL(convert(nvarchar, mailing_country), '')
                            )
                    , 2)
	UNION ALL
	SELECT
        s.uuid,
        s.ADLSBatchID	,
        s.ADLSTimestamp	,
        s.LZBatchID		,
        s.lead_id         ,
        s.user_type       ,
        s.remote_care_invite_status ,
        s.remote_care_accept_terms ,
        TRY_CONVERT(datetime,LEFT(s.created_date,19)) as created_date    ,
        TRY_CONVERT(datetime,LEFT(s.updated_date,19)) as updated_date    ,
        s.is_app_user     ,
        s.is_demo   ,
	    NULL AS SequenceNumber,
	    s._timestamp,
	    s.clin_id,
	    s.mailing_country
    from SrcKafkaHeroku.user_profile_event s
	JOIN #UUIDsToLoad u on u.uuid=s.uuid

	IF OBJECT_ID('TEMPDB..#TEMPSATAPIUSER') IS NOT NULL
	DROP TABLE #TempSatAPIUser

	CREATE TABLE #TempSatAPIUser WITH (DISTRIBUTION = HASH(uuid), HEAP) AS
    SELECT
        hu.SKAPIUser,
        s.uuid,
        s.ADLSBatchID					as ADLSBatchID,
        s.ADLSTimestamp					as ADLSTimestamp,
        s.LZBatchID						as LZBatchID,
        convert(char(40), '')			as DWHash,
        s.lead_id         ,
        CONVERT(varchar(50),NULL) AS clin_id         ,
        CONVERT(INT,NULL) AS SKContact       ,
        s.user_type       ,
        CONVERT(nvarchar(50),NULL) AS mailing_country ,
        s.remote_care_invite_status ,
        s.remote_care_accept_terms ,
        s.created_date    ,
        s.updated_date    ,
        s.is_app_user     ,
        s.is_demo         ,
        CONVERT(varchar(50),NULL) as InitialUserType,
        CONVERT(datetime,NULL) AS ConvertedToProspect,
        CONVERT(datetime,NULL) AS ConvertedToPatient,
        CONVERT(INT,NULL) AS SKGeography
    FROM (
        Select TOP 1 WITH TIES
            s.uuid,
            s.ADLSBatchID					as ADLSBatchID,
            s.ADLSTimestamp					as ADLSTimestamp,
            s.LZBatchID						as LZBatchID,
            s.lead_id         ,
            s.user_type       ,
            s.remote_care_invite_status ,
            s.remote_care_accept_terms ,
            s.created_date  ,
            s.updated_date  ,
            s.is_app_user     ,
            s.is_demo ,
            s.clin_id
        from #LeadHistory s
        ORDER BY ROW_NUMBER() OVER (
                PARTITION BY s.uuid
                ORDER BY
                    CASE
                        WHEN s.user_type = 'patient'	THEN 1
                        WHEN s.user_type = 'prospect'	THEN 2
                        WHEN s.user_type = 'lead'		THEN 3
                        ELSE 4
                    END,
                    s.updated_date DESC,
                    s._timestamp DESC,
                    s.SequenceNumber DESC
                )/*RowNumber*/
        ) s
    JOIN DWMyInvisalignApp.HubAPIUser hu on hu.KeyAPIUser = s.uuid

    UPDATE #TempSatAPIUser
    SET InitialUserType = Initial.user_type
    FROM (
            SELECT TOP 1 WITH ties
                u.uuid,
                u.user_type
            FROM #LeadHistory u
            WHERE u.user_type in ('lead','prospect','patient')
            ORDER BY ROW_NUMBER() OVER (
                PARTITION BY u.uuid
                ORDER BY
                    CASE WHEN u.user_type = 'lead' THEN 1
                    WHEN u.user_type = 'prospect' THEN 2
                    ELSE 3
                    END,
                    u._timestamp,
                    u.SequenceNumber
                )/*RowNumber*/
        ) as Initial
    WHERE Initial.uuid=#TempSatAPIUser.uuid

    UPDATE #TempSatAPIUser
    SET ConvertedToProspect =ConvertedToProspect.converted
    FROM (
        Select
            u.uuid,
            MIN (updated_date) as converted
        from #LeadHistory u
        where u.user_type ='prospect'
        and updated_date IS NOT NULL
        group by u.uuid
        ) as ConvertedToProspect
    WHERE ConvertedToProspect.uuid=#TempSatAPIUser.uuid
    and #TempSatAPIUser.InitialUserType ='lead'

    UPDATE #TempSatAPIUser
    SET ConvertedToPatient =ConvertedToPatient.converted
    FROM (
        Select
            u.uuid,
            MIN (updated_date) as converted
        from #LeadHistory u
        where u.user_type ='patient'
        and updated_date IS NOT NULL
        group by u.uuid
        ) as ConvertedToPatient
    WHERE ConvertedToPatient.uuid=#TempSatAPIUser.uuid
    and #TempSatAPIUser.InitialUserType IN ('lead','prospect')

    update #TempSatAPIUser
    set clin_id=LastClinID.clin_id
    from (
            SELECT TOP 1 WITH ties
                u.uuid,
                CASE
                   WHEN CHARINDEX('$', u.clin_id) > 0
                   THEN SUBSTRING(u.clin_id, 0, CHARINDEX('$', u.clin_id))
                   ELSE u.clin_id
                END as clin_id
            FROM #LeadHistory u
            WHERE u.user_type in ('lead','prospect','patient')
                and u.clin_id is not null
            ORDER BY ROW_NUMBER() OVER (
                PARTITION BY u.uuid
                ORDER BY
                    CASE WHEN u.user_type = 'lead' THEN 1
                    WHEN u.user_type = 'prospect' THEN 2
                    ELSE 3
                    END DESC,
                    u.updated_date DESC,
                    u._timestamp DESC,
                    u.SequenceNumber DESC
                )/*RowNumber*/
        ) as  LastClinId
         where LastClinId.uuid=#TempSatAPIUser.uuid

    UPDATE #TempSatAPIUser
    SET mailing_country=LastCountry.mailing_country
    from (
            SELECT TOP 1 WITH ties
                u.uuid,
                u.mailing_country
            FROM #LeadHistory u
            WHERE u.user_type in ('lead','prospect','patient')
                and u.mailing_country is not null
            ORDER BY ROW_NUMBER() OVER (
                PARTITION BY u.uuid
                ORDER BY
                    CASE WHEN u.user_type = 'lead' THEN 1
                    WHEN u.user_type = 'prospect' THEN 2
                    ELSE 3
                    END DESC,
                    u.updated_date DESC,
                    u._timestamp DESC,
                    u.SequenceNumber DESC
                )/*RowNumber*/
        ) as  LastCountry
         where LastCountry.uuid=#TempSatAPIUser.uuid

    UPDATE #TempSatAPIUser
    SET SKGeography=CombinedName.SKGeography
    from (
        Select
            N';'+COALESCE(CountryCode,N'') +
            N';'+COALESCE(Country,N'') +
            N';'+COALESCE(CountryGoogleName,N'') +
            N';' as CombinedName,
             Country,
            SKGeography
        from  [Custom].[GeographyHierarchy]
            ) as CombinedName
             where CombinedName.CombinedName like N'%;'+#TempSatAPIUser.mailing_country+N';%'

	UPDATE #TempSatAPIUser
	SET SKContact = c.SKContact
	FROM DW.DimContact c
	where c.ClinID=#TempSatAPIUser.clin_id

	UPDATE #TempSatAPIUser set DWHash=
		CONVERT(char(40),
			HASHBYTES('SHA1',
						ISNULL(convert(nvarchar,lead_id),'')
					+'|'+ISNULL(convert(nvarchar,clin_id),'')
					+'|'+ISNULL(convert(nvarchar,SKContact),'')
					+'|'+ISNULL(convert(nvarchar,user_type),'')
					+'|'+ISNULL(convert(nvarchar,mailing_country),'')
					+'|'+ISNULL(convert(nvarchar,remote_care_invite_status),'')
					+'|'+ISNULL(convert(nvarchar,remote_care_accept_terms),'')
					+'|'+ISNULL(convert(nvarchar,created_date),'')
					+'|'+ISNULL(convert(nvarchar,updated_date),'')
					+'|'+ISNULL(convert(nvarchar,is_app_user),'')
					+'|'+ISNULL(convert(nvarchar,is_demo),'')
					+'|'+ISNULL(convert(nvarchar,InitialUserType),'')
					+'|'+ISNULL(convert(nvarchar,ConvertedToProspect),'')
					+'|'+ISNULL(convert(nvarchar,ConvertedToPatient),'')
					+'|'+ISNULL(convert(nvarchar,SKGeography),'')
				)
			,2)



	--   Create Unknow Element in case there is none
	IF NOT EXISTS (SELECT * FROM DWMyInvisalignApp.SatAPIUser WHERE SKAPIUser = -1)
	BEGIN
		DECLARE @Hash CHAR(40) = ''
		INSERT INTO DWMyInvisalignApp.SatAPIUser (
				SKAPIUser,
				ADLSBatchID,
				ADLSTimestamp,
				LZBatchID,
				DWBatchID,
				DWHash
		)
		SELECT
				-1 as SKUser,
				-1 as ADLSBatchID,
				'2000-01-01' as ADLSTimestamp,
				0 as LZBatchID,
				0 as DWBatchID,
				@Hash as DWHash
	END
	--  End  createing unknow element

	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	UPDATE DWMyInvisalignApp.SatAPIUser
		set
		    ADLSBatchID = src.ADLSBatchID,
			ADLSTimestamp = src.ADLSTimestamp,
			LZBatchID = src.LZBatchID,
			DWBatchID = @BatchID,
			DWHash = src.DWHash,
            lead_id = src.lead_id        ,
            clin_id = src.clin_id         ,
		    SKContact = src.SKContact       ,
            user_type = src.user_type      ,
            mailing_country = src.mailing_country ,
            remote_care_invite_status = src.remote_care_invite_status ,
            remote_care_accept_terms = src.remote_care_accept_terms ,
            created_date = src.created_date    ,
            updated_date = src.updated_date    ,
            is_app_user = src.is_app_user     ,
            is_demo = src.is_demo,
		    InitialUserType = src.InitialUserType,
		    ConvertedToProspect = src.ConvertedToProspect,
		    ConvertedToPatient = src.ConvertedToPatient,
            SKGeography = src.SKGeography
	from #TempSatAPIUser src
	where DWMyInvisalignApp.SatAPIUser.SKAPIUser = src.SKAPIUser
		and DWMyInvisalignApp.SatAPIUser.DWHash != src.DWHash
	option (label = 'DWMyInvisalignApp.LoadSatAPIUser');

	exec CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatAPIUser', @rc = @RowsUpdated out


	--INSERT new rows
	INSERT DWMyInvisalignApp.SatAPIUser (
		SKAPIUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		DWBatchID,
		DWHash,
        lead_id         ,
        clin_id         ,
	    SKContact       ,
        user_type       ,
        mailing_country ,
        remote_care_invite_status ,
        remote_care_accept_terms ,
        created_date    ,
        updated_date    ,
        is_app_user     ,
        is_demo         ,
	    InitialUserType ,
	    ConvertedToProspect,
	    ConvertedToPatient,
        SKGeography

		)
	SELECT
		SKAPIUser,
		ADLSBatchID,
		ADLSTimestamp,
		LZBatchID,
		@BatchID as DWBatchID,
		DWHash,
        lead_id         ,
        clin_id         ,
	    SKContact       ,
        user_type       ,
        mailing_country ,
        remote_care_invite_status ,
        remote_care_accept_terms ,
        created_date    ,
        updated_date    ,
        is_app_user     ,
        is_demo         ,
   	    InitialUserType ,
	    ConvertedToProspect,
	    ConvertedToPatient,
        SKGeography
	FROM #TempSatAPIUser src
	WHERE not exists(
		SELECT dst.SKAPIUser
		FROM DWMyInvisalignApp.SatAPIUser dst
		WHERE dst.SKAPIUser = src.SKAPIUser
	)
	OPTION (LABEL = 'DWMyInvisalignApp.LoadSatAPIUser');

	EXEC CTRL.GetLastRowCount @Label = 'DWMyInvisalignApp.LoadSatAPIUser', @rc = @RowsInserted out

	SELECT @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated

END