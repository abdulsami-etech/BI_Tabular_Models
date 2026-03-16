CREATE PROC [DWTOPS].[LoadFactLotLeadTimeCCMod] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
              set xact_abort on
              
              declare @RowsInserted int = 0
                             ,             @RowsUpdated              int = 0
                             ,             @IsFullLoad                     bit = 0
              --,@LastSuccessfullDWTimestamp [datetime2](0) ,@BatchID [int]
              if not exists (select * from DWTOPS.FactLotLeadTimeCCMods)
                             set @IsFullLoad = 1

              IF OBJECT_ID('tempdb..#WorkingTrackedObjHistory') IS NOT NULL
              DROP TABLE #WorkingTrackedObjHistory

              IF OBJECT_ID('tempdb..#epub') IS NOT NULL
              DROP TABLE  #epub

              IF OBJECT_ID('tempdb..#epubMTP') IS NOT NULL
              DROP TABLE  #epubMTP

              IF OBJECT_ID('tempdb..#MTP_Cases') IS NOT NULL
              DROP TABLE  #MTP_Cases

              IF OBJECT_ID('tempdb..#Cases') IS NOT NULL
              DROP TABLE  #Cases

              
              IF OBJECT_ID('tempdb..#AllCases') IS NOT NULL
              DROP TABLE  #AllCases

              IF OBJECT_ID('tempdb..#IDSTras') IS NOT NULL
              DROP TABLE  #IDSTras
              
                             
              IF OBJECT_ID('tempdb..#HOLD_TIME') IS NOT NULL
              DROP TABLE #HOLD_TIME

                                           
              IF OBJECT_ID('tempdb..#Final') IS NOT NULL
              DROP TABLE #Final

              
              if object_id ('DWTOPS.Temp_LeadTimeOrdersToLoadCCmod', 'U') is not null
                             drop table DWTOPS.Temp_LeadTimeOrdersToLoadCCmod
    
              create table DWTOPS.Temp_LeadTimeOrdersToLoadCCmod (OrderNumber nchar(18) not null) with (distribution = round_robin, heap)
              ALTER TABLE DWTOPS.Temp_LeadTimeOrdersToLoadCCmod ADD CONSTRAINT PK_Temp_LeadTimeOrdersToLoadCCMOD PRIMARY KEY NONCLUSTERED (OrderNumber) NOT ENFORCED

              
              if @IsFullLoad = 0
              begin
                             insert into DWTOPS.Temp_LeadTimeOrdersToLoadCCmod (OrderNumber)

                             select    d.[order_number]
                             FROM [SrcMESCorp].[tracked_object_history]  as a
                             inner join [SrcMESCorp].[LOT]  as c
                             on c.[lot_key]=a.[tobj_key]
                             inner join [SrcMESCorp].[Work_Order] as d
                             on d.order_key=c.order_key
                             where a.ADLSTimestamp >= @LastSuccessfullDWTimestamp
                                           
                             union

                             SELECT b.[jde_order_id]
                             FROM [SrcIDS].[tblpuorderstatushistory] AS a
                             inner join (SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) AS b ON a.vip_order_id=b.viP_order_id and a._Region = b._Region and b.latest =1
                             AND a.event_type in ('RxFormTranslated','RxFormInTranslation','ClinCheckTranslated','ClinCheckInTranslation') -- Tagging time already considers Translation time?!
                             AND cc_mod_count >0 ----CCmods
                             where 
                              b.[jde_order_id] is not null and
                             [modified_date] >= DATEADD(HOUR,-8,@LastSuccessfullDWTimestamp)
              end



              --Get the Distinct Lot History from last Run
              CREATE TABLE #WorkingTrackedObjHistory
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
              SELECT 
                             a.[ADLSBatchID]
                             ,a.[ADLSTimestamp]
                             ,a.[LZBatchID]
                             ,a.[tobj_history_key]
                             ,a.[tobj_key]
                             ,a.[route_name]
                             ,a.[op_name]
                             ,a.[complete_reason]
                             ,a.[complete_count]
                             ,a.[complete_time_u] 
                             ,a.[start_time_u]
                             ,d.[order_number]
                             ,e.[at_storagelocation_s]
                             ,p.[Category]
                             FROM [SrcMESCorp].[tracked_object_history]  as a
                             inner join [SrcMESCorp].[LOT]  as c
                             on c.[lot_key]=a.[tobj_key]
                             inner join [SrcMESCorp].[Work_Order] as d
                             on d.order_key=c.order_key
                             inner join [SrcMESCorp].[UDA_Order] as e
                             on d.order_key=e.Object_Key
                             inner join [SrcMESCorp].[PART]  as p
                             on p.part_number=c.part_number
                             and p.part_revision=c.part_revision
                             where a.complete_time_u >= '20160101' and 
                             (        @IsFullLoad = 1
                                 or      
                                           d.[order_number] in (Select OrderNumber from DWTOPS.Temp_LeadTimeOrdersToLoadCCmod) )


              --Get the Distinct Lot History from last Run

              CREATE TABLE #ePub
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
                             SELECT 
                             a.[ADLSBatchID]
                             ,a.[ADLSTimestamp]
                             ,a.[LZBatchID]
                             ,a.[tobj_history_key]
                             ,a.[tobj_key]
                             ,a.[route_name]
                             ,a.[op_name]
                             ,a.[complete_reason]
                             ,a.[complete_count]
                             ,a.[complete_time_u]
                             ,a.[start_time_u]
                             ,a.[order_number]
              FROM #WorkingTrackedObjHistory  as  a        
                             WHERE
                                           a.route_name <> 'TX MTP Case Setup' AND 
                                           a.op_name  =  'ePub'
                                           AND
                                           a.complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2', 'OK')    
                                           AND
                                           a.complete_count >1
                                           AND
                                           a.complete_time_u >= '20160101' 
                                           AND 
                                   (  @IsFullLoad = 1
                                 or      
                                           a.[order_number] in (Select OrderNumber from DWTOPS.Temp_LeadTimeOrdersToLoadCCmod) )


--/*********************************************************************
--START - ALTA GO LOGIC 
--**********************************************************************/

--            -- GATHER ALL THE MTP CASES THAT ARRIVE TO EPUB OK

              
CREATE TABLE #epubMTP
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
              SELECT  DISTINCT
                             TOH.tobj_key
                             ,TOH.Order_number
                             ,TOH.complete_time_u 
                             ,ROW_NUMBER ()  OVER (PARTITION BY TOH.tobj_key,TOH.Order_number ORDER BY TOH.complete_time_u) [ord_end]

              FROM #WorkingTrackedObjHistory as TOH
              WHERE
                             TOH.route_name = 'TX MTP Case Setup'
                             AND
                             TOH.op_name  ='ePub'
                             AND
                             TOH.complete_reason  IN  ('Auto 1', 'Auto 2', 'Auto2', 'OK')    
                             AND TOH.complete_count >1 --CCmods

              
CREATE TABLE #MTP_CASES
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
              SELECT
                             end_op.tobj_key
                             ,start_op.[start_complete_time_u]
                             ,end_op.complete_time_u
                             ,start_op.[ord_start]
                             ,end_op.Order_number
              FROM
              #epubMTP end_op
              inner join
              (
                             SELECT distinct
                                                          CCMod.tobj_key
                                           ,CCMod.Order_number
                                           ,CCMod.op_name
                                           ,CCMod.complete_time_u [start_complete_time_u]
                                           ,ROW_NUMBER() OVER (PARTITION BY CCMod.tobj_key,CCMod.Order_number ORDER BY CCMod.complete_time_u) [ord_start]
                             FROM 
                                           #WorkingTrackedObjHistory  as CCMod
                             WHERE 
                             
                                           
                                           ((CCMod.op_name ='ClinCheck' and CCMod.complete_reason ='Fail')
                                           OR
                                           (CCMod.op_name = 'MTP' and not CCMod.complete_reason IN ('Fail','Approved')))
              ) start_op 
              ON start_op.tobj_key = end_op.tobj_key AND start_op.Order_number = end_op.Order_number
              AND start_op.[ord_start] = end_op.[ord_end]


              
/*********************************************************************
END - ALTA GO LOGIC 
**********************************************************************/


CREATE TABLE #cases
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
                 SELECT 
                                                                        CCMod.tobj_key, 
                                                                        CCMod.complete_time_u AS [CCModStartTime],
                                                                        epub.complete_time_u AS [EpubCompleteTime],
                                                                        epub.complete_count,
                                                                        CCMod.order_number 
                                                                        FROM 
                                                                        #WorkingTrackedObjHistory CCMod 
                                                                        INNER JOIN 
                                                                        #ePub epub ON epub.tobj_key = CCMod.tobj_key  AND CCMod.complete_time_u < epub.complete_time_u AND ccmod.complete_count + 1 = epub.complete_count
                                                          WHERE 
                                                                        CCMod.op_name IN ('ClinCheck') and CCmod.complete_reason IN ('Fail')-- 'NaN'--in ('Fail','Switch','Switch_1')
              UNION

              SELECT  * FROM #MTP_CASES                  

              ------------ Derive hold times
CREATE TABLE #Allcases
              WITH (
                             DISTRIBUTION = HASH([tobj_key]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
  SELECT  
         
           	
           TOH.tobj_key,TOH.CCModStartTime,TOH.ePubCompleteTime,TOH.complete_count ,TOH.order_number,
            DATEDIFF(HOUR,TOH.CCModStartTime,TOH.ePubCompleteTime) AS [HOURS],
            [hold] = ISNULL((   
                                                                                      SELECT SUM(ISNULL(DATEDIFF(hh,HOLD_TOH.start_time_u,HOLD_TOH.complete_time_u),0))
                        FROM             
                           #WorkingTrackedObjHistory HOLD_TOH
                        WHERE      
                            HOLD_TOH.op_name  IN  ('Clinical Hold', 'Materials Pending')
                            AND 
                            HOLD_TOH.tobj_key = TOH.tobj_key
                            AND 
                            HOLD_TOH.complete_time_u BETWEEN TOH.CCModStartTime AND TOH.ePubCompleteTime

                        GROUP BY HOLD_TOH.tobj_key ),0),
                                           ROW_NUMBER() OVER (partition by AT.Order_number  order by TOH.CCModStartTime ) as CCModCntDerived            
  
        FROM
            
                                           #Cases TOH
            INNER JOIN                        
            #WorkingTrackedObjHistory AT  ON AT.tobj_key=TOH.tobj_key AND AT.Category NOT IN('Asset Scan', 'Retainer')
     Group by TOH.tobj_key,TOH.CCModStartTime,TOH.ePubCompleteTime,TOH.complete_count ,TOH.order_number,AT.Order_number



              


----------get IDS Translations time---   Added by efernandez 01/15/2018
     
CREATE TABLE #IDSTras
              WITH (
                             DISTRIBUTION = HASH([jde_order_id]),
                             CLUSTERED COLUMNSTORE INDEX
              )  
              AS
                             SELECT T.[jde_order_id],
                                                          [modified_date],
                                                          ROW_NUMBER() OVER (PARTITION BY T.[jde_order_id] order by T.[modified_date]) as CCModCntDerived,
                                                          [translationtime] AS [transaltiontime]
                             FROM ( SELECT *,DATEDIFF(HOUR,a.[start_date],a.[nextEvent_Time]) AS [translationtime]
                                                          FROM ( SELECT
                                                                                                     r.[jde_order_id]
                                                                                                     ,r.[event_type]
                                                                                                     ,r.[event_id]
                                                                                                    ,CONVERT(VARCHAR(10),r.[modified_date],101) AS [modified_date]
                                                                                                     ,r.[modified_date] [start_date]
                                                                                                    ,lead(r.[event_type]) OVER (PARTITION BY r.[jde_order_id] ORDER BY r.[modified_date]) nextEvent_Type
                                                                                                    ,lead(r.[modified_date]) OVER (PARTITION BY r.[jde_order_id] ORDER BY r.[modified_date]) nextEvent_Time
                                                                                      FROM(  SELECT 
                                                                                                                                   [event_type]
                                                                                                                                 ,[event_id]
                                                                                                                                 ,[modified_date]
                                                                                                                                 ,[jde_order_id]
                                                                                                                                 ,cc_mod_count
                                                                                                                                 ,MIN(modified_date) OVER (PARTITION BY [event_id]) AS lastEvent                                           -- Get only the first event when 'event_id' is duplicated
                                                                                                                   FROM 
                                                                                                                                 SrcIDS.[tblpuorderstatushistory] AS a
                                                                                                                                 INNER JOIN 
                                                                                                                                 (SELECT jde_order_id,vip_order_id,_Region, Row_number()over(partition by jde_order_id,vip_order_id order by case when _Region = 'Global' then 1 else 0 end ) AS latest FROM SrcIDS.tblcnpatientordermap) AS b ON a.vip_order_id=b.viP_order_id and a._Region = b._Region and b.latest =1
                                                                                                                                  --WHERE [jde_order_id]='23742187'
                                                                                                                                                AND a.event_type IN ('RxFormTranslated','RxFormInTranslation','ClinCheckTranslated','ClinCheckInTranslation')
                                                                                                                                                AND cc_mod_count <> 0                                                                                                                                                                            -- Removing Intial Order
                                                                                                                                                AND EXISTS (  SELECT 1 FROM DWTOPS.Temp_LeadTimeOrdersToLoadCCmod as al where al.OrderNumber=b.[jde_order_id])                                                                                                              
                                                                                                     ) r WHERE lastEvent = [modified_date]
                                                                        ) a
                                                          WHERE a.nextEvent_Time IS NOT NULL                                                                                                                                                                                                            -- Delete the last not associated row (not end time)
                                                                        AND 
                                                                        a.[event_type] = 'ClinCheckInTranslation' 
                                           
                                           ) T

                                                                           
              CREATE TABLE #Final
              WITH (
                             DISTRIBUTION = HASH([DgnLotKey]), heap

              )  
              AS
                                           SELECT at.ADLSBatchID,
                                                          at.ADLSTimestamp,
                                                          at.LZBatchID,
                                               TOH.EpubCompleteTime AS [DgnCompleteDateTime],
                                                          TOH.[tobj_key] as [DgnLotKey],
                                                          ISNULL(CONVERT(VARCHAR(8), TOH.EpubCompleteTime, 112), -1) AS [SKCompleteDate],
                                                          ISNULL(IDT.transaltiontime,0) AS [TranslationHours],
                                                          ISNULL(TOH.[hold],0) AS [HoldTimeHours],
                                                          (TOH.[HOURS] + ISNULL(IDT.transaltiontime,0))  - ISNULL(TOH.Hold,0) AS [LeadTimeHour],
                                                          TOH.CCModCntDerived as [CCModCount]--Firstpass

                                           FROM
                                                          (Select tobj_key
                                                                        ,order_number
                                                                        ,min([ADLSBatchID]) as ADLSBatchID
                                                                        ,min([ADLSTimestamp]) as ADLSTimestamp
                                                                        ,min([LZBatchID]) as LZBatchID
                                                                        from #WorkingTrackedObjHistory
                                                                        group by tobj_key , order_number 
                                                          ) as AT
                                                          INNER JOIN
                                                          #Allcases TOH WITH (NOLOCK) ON (AT.tobj_key=TOH.tobj_key)
                                                          LEFT JOIN 
                                                          #IDSTras as IDT ON IDT.[jde_order_id]=TOH.order_Number 
                                                          and TOH.CCModCntDerived = IDT.CCModCntDerived  



              begin tran

   DELETE FROM [DWTOPS].[FactLotLeadTimeCCMods]
              WHERE EXISTS (
                             SELECT * FROM #Final s
                             WHERE s.[DgnLotKey] = [DWTOPS].[FactLotLeadTimeCCMods].[DgnLotKey]
              )

              exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactPatientOrderCCmods_Delete', @rc = @RowsUpdated out
              

      INSERT INTO [DWTOPS].[FactLotLeadTimeCCmods]
           ([ADLSBatchID]
            ,[ADLSTimestamp]
            ,[LZBatchID]
           ,[DWBatchID]
           ,[DgnCompleteDateTime]
           ,[DgnLotKey]
           ,[SKCompleteDate]
           ,[TranslationHours]
           ,[HoldTimeHours]
           ,[LeadTimeHour]
           ,[CCModCount])
        Select 
            [ADLSBatchID]
            ,[ADLSTimestamp]
            ,[LZBatchID]
            ,@BatchId
           ,[DgnCompleteDateTime]
           ,[DgnLotKey]
           ,[SKCompleteDate]
           ,[TranslationHours]
           ,[HoldTimeHours]
           ,[LeadTimeHour]
           ,[CCModCount]                  
            from #Final
            where [LeadTimeHour]>=0
            option (label = 'DWTOPS.LoadFactLotLeadTimeCCMods_Insert');

              exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotLeadTimeCCmods_Insert', @rc = @RowsInserted out

              commit tran

              select @RowsInserted - @RowsUpdated as RowsInserted, @RowsUpdated as RowsUpdated



END
