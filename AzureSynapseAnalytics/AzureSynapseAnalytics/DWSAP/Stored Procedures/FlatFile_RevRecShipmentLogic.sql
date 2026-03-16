CREATE PROC [DWSAP].[FlatFile_RevRecShipmentLogic] @BATCHID [INT],@LASTSUCCESSFULLDWTIMESTAMP [DATETIME2](0) AS 
    BEGIN
      DECLARE @LASTDATETIME AS DATETIME2, 
      @ROWSINSERTED INT = 0 , 
      @ROWSUPDATED INT = 0 , 
      @ISFULLLOAD BIT = 0 IF (EXISTS 
      (
        SELECT
          * 
        FROM
          INFORMATION_SCHEMA.TABLES 
        WHERE
          TABLE_SCHEMA = 'DWSAP' 
          AND TABLE_NAME = 'RevRecShipVolProcessed'
      )
) 
      BEGIN
        SET
          @LASTDATETIME = 
          (
            SELECT
              MAX(ADLSTIMESTAMP) 
            FROM
              [DWSAP].[RevRecShipVolProcessed]
          )
      END
      ELSE
        BEGIN
          SET
            @LASTDATETIME = '1900-01-01 12:00:00' 
        END
        --The above statement checks that the table "RevRecShipVolProcessed" is present in the datawarehouse or not,
        -- if present than getting the Max of ADLSTimestamp and storing it into variable for incremental inserts.
        SELECT
          * INTO #TEMP_REVREC 
        FROM
          (
            -- selecting fields and storing it into a temp table named as #temp_revrec
            SELECT
              RS.[LZBATCHID],
              RS.[ADLSBATCHID],
              RS.[ADLSTIMESTAMP],
              @BATCHID [DWBATCHID],
              @LASTSUCCESSFULLDWTIMESTAMP [DWTIMESTAMP],
              RS.[PROFITCENTER],
              --Jira Number BI-11966
			  -- Removing Leading Zeros from the Sales Order Numbers Coming from the source Flat File.
              REPLACE(LTRIM(REPLACE(RS.[ORDERNUMBER], '0', ' ')), ' ', '0') AS [ORDERNUMBER],
              RS.[PARTNUMBER],
              RS.[DOCUMENTTYPE],
              RS.[INVOICEDATE],
              RS.[COUNT],              
			  
							
              'K4' [FISCAL VARIANT] 							-- Hard Code for Fiscal Variant
,
              'F' [FILEYN] 							-- Hard Code for File 
,
              CAST(GETDATE() AS DATE) [CREATEDONDATE] 							-- Setting CreatedDate as current date
,
              GETDATE() [CREATEDON],
              CURRENT_USER [USER] 							-- Setting Fields for Created datetime and Current user
,
              'REVREC SHIPMENTS' [SEGMENT],
              'REVREC SHIPMENTS' [VOLUME SEGMENT],
              'REVREC SHIPMENTS' [VOLUME SUB-SEGMENT] 							-- HardCoding Segment, Volume Segment and Sub-Segment
,
              CASE
                WHEN
                  (
                    OA.[AGETIERCODE] >= 0 
                    AND OA.[AGETIERCODE] <= 19
                  )
                THEN
                  'REVREC_SHIPMENTS_TEENAGERS' 
                WHEN
                  OA.[AGETIERCODE] >= 20 
                  AND OA.[AGETIERCODE] <= 110 
                  OR 
                  (
                    OA.[AGETIERCODE] = - 1
                  )
                THEN
                  'REVREC_SHIPMENTS_ADULTS' 
                WHEN
                  VBAP.[PRODH] IN 
                  (
                    SELECT
                      [OPERAND1] 
                    FROM
                      [DWSAP].[ZTB_VOLME_CONFIG] 
                    WHERE
                      NAME = 'NONCASE'
                  )
                THEN
                  'REVREC_SHIPMENTS_MISCELLANEOUS' 
                WHEN
                  OA.[AGETIERCODE] IS NULL 
                THEN
                  'REVREC_SHIPMENTS_AGE UNKNOWN' 
                ELSE
                  'REVREC SHIPMENTS UNKNOWN' 
              END
              AS [COST ELEMENT] 							
			  -- Defining Cost Element based on Age Group i.e. when age >0 and age <= 19 then Teens
              --, when age >19 then adults, when production hierarchy lies from any Noncase from Config table than Miscellaneous
              -- else Unknon
, 'Volume' [PROCESS NAME] 							-- Hard Code to Volume
, OA.[TREATMENTLOCATION], OA.[TREATINGDOCTOR], CC.CERTIFICATIONDATE, YEAR(CC.CERTIFICATIONDATE) CERTIFICATIONYEAR , CC.ADVANTAGETIER, CC.PROFESSIONALCATEGORY, CA.[COUNTRY], CA.[COUNTRYGROUP], CA.[REGIONPC], CA.[REGIONGROUP], CA.[GLOBALREGION] 							-- Getting Fields from Order and Customer details tables/views i.e OA alias to OrderAttributes, CC alias to CustomerContact
              -- and CA alias to CustomerAccount Views.
, 
              CASE
                WHEN
                  VBAP.[PRODH] LIKE 'A1A1%' 
                THEN
                  'CLEAR ALIGNER' 
                WHEN
                  VBAP.[PRODH] LIKE 'A1S1%' 
                THEN
                  'ITERO' 
                ELSE
                  NULL 
              END
              AS [BUSINESS SEGMENT] 							
			  -- Defining Business Segment based on Product hierarchy field from VBAK
, LIPS.[VBELN] [DELIVERY]
, VBAP.[PRODH] [PRODUCT HIERARCHY]
, VBAP.[VOLUM] [VOLUME]
, VBAP.[VOLEH] [VOLUME UNIT] 
, OA.SHIPTO [SHIP-TO PARTY]
, OA.SOLDTO [SOLD-TO PARTY]
, LIKP.[NTGEW] [NET WEIGHT] 
, LIKP.[BTGEW] [TOTAL WEIGHT]
, VBAK.[VKORG] [SALES ORGANIZATION]
, LIKP.[WADAT_IST] [SHIPMENT DATE] 
,vbak.[ZZSR_NO] as [Serial Number]
,vbak.[ZZ_IN_COM_ID] as [Initiator Company ID]
, VBAK.[SPART] [DIVISION], VBAK.[KOKRS] [CONTROLLING AREA]
, VBAP.[MATNR] [MATERIAL NUMBER]
, LIPS.[LFIMG] [DELIVERY QUANTITY] 
, VBAP.[PSTYV] [ITEM CATEGORY],

 --Jira Number BI-11966
 -- Removing Leading Zeros from the Sales Order Item coming from VBAP
REPLACE(LTRIM(REPLACE(VBAP.POSNR, '0', ' ')), ' ', '0') [SALESORDER ITEM]
,VBAP.[ZZTOTAL_QTY] [TOTAL QUANTITY] 
,VBAP.[ZZTOT_QTY] [DELIVERABLE QUANTITY]
,VBAK.[ZZDELI_CATE] [TREATMENT CATEGORY]
,VBAP.[ZZDELI_TYPE] [DELIVERABLE TYPE] 
,OA.[AGETIERCODE] [AGE TIER], VBAP.[KWMENG] [ORDER QUANTITY]
,VBAK.[ZZDELI_CATE] [DELIVERABLE CATEGORY] 
,VBAK.[ZZCOMP_IND] [COMPLIANCE INDICATOR] 							-- Extracting fields from VBAK, VBAP, LIKP and LIPS base tables.
,'RevRecFlatfile' [VOLUMEFLAG] 							
-- HardCoding VolumeFlag 
, 
              CASE
                WHEN
                  VBAK.[VTWEG] = '20' 
                THEN
                  21 
                WHEN
                  VBAK.[VTWEG] = '10' 
                  AND VBAK.[KVGR1] = '01' 
                THEN
                  11 
                WHEN
                  VBAK.[VTWEG] = '10' 
                  AND VBAK.[KVGR1] = '02' 
                THEN
                  12 
                WHEN
                  VBAK.[VTWEG] = '10' 
                  AND VBAK.[KVGR1] = '03' 
                THEN
                  13 
                WHEN
                  VBAP.[PRODH] LIKE 'A1S1%' 
                  AND VBAP.[MVGR5] = 'Z3' 
                THEN
                  11 
                WHEN
                  VBAP.[PRODH] LIKE 'A1S1%' 
                  AND VBAP.[MVGR5] = 'Z2' 
                THEN
                  12 
                WHEN
                  VBAP.[PRODH] LIKE 'A1S1%' 
                THEN
                  12 
                WHEN
                  VBAP.[PRODH] = 'A1A1T1C10301' 
                THEN
                  11 
                ELSE
                  12 
              END
              [REPORTING CHANNEL] 							
			  -- Deriving Reporting Channel based on conditions
, VBAP.[MANDT] [PLANT], LIPS.POSNR [DELIVERYITEM] 
            FROM
              [SRCSAPFILE].[REVRECSHIPVOL] RS 
              LEFT JOIN
                [TABSAP].[DIMORDERATTRIBUTES] OA 
                ON RS.[ORDERNUMBER] = OA.[ORDERNUMBER] 
              LEFT JOIN
                [TABSAP].[DIMCUSTCONTACT] CC 
                ON CC.[CLINID] = OA.[CLINID] 
              LEFT JOIN
                [TABSAP].[DIMCUSACCOUNT] CA 
                ON CA.[ACCOUNTNUMBER] = OA.[TREATMENTLOCATION] 
              LEFT JOIN
                [SRCSAP].[VBAK] VBAK 
                --Jira Number BI-11966
                --Removing Leading zeros while applying joins
                ON REPLACE(LTRIM(REPLACE(RS.ORDERNUMBER, '0', ' ')), ' ', '0') = REPLACE(LTRIM(REPLACE(VBAK.[VBELN], '0', ' ')), ' ', '0') 
              LEFT JOIN
                [SRCSAP].[VBAP] VBAP 
                ON REPLACE(LTRIM(REPLACE(RS.ORDERNUMBER, '0', ' ')), ' ', '0') = REPLACE(LTRIM(REPLACE(VBAP.[VBELN], '0', ' ')), ' ', '0') 
                --AND VBAP.MATNR = CONCAT('00000000000000', RS.[PARTNUMBER])
				AND VBAP.PSTYV != 'Z000'
                AND VBAP.PRCTR = CONCAT('000000', RS.[PROFITCENTER]) 
                AND VBAK.[AUART] = RS.[DOCUMENTTYPE] 
              LEFT JOIN
                [SRCSAP].[LIPS] [LIPS] 
                ON REPLACE(LTRIM(REPLACE(RS.ORDERNUMBER, '0', ' ')), ' ', '0') = REPLACE(LTRIM(REPLACE(LIPS.[VGBEL], '0', ' ')), ' ', '0') 
                AND LIPS.[VGPOS] = VBAP.[POSNR] 
              LEFT JOIN
                [SRCSAP].[LIKP] [LIKP] 
                ON LIPS.[VBELN] = LIKP.[VBELN] 
            WHERE
              RS.ADLSTIMESTAMP > COALESCE(@LASTDATETIME, '1900-01-01 12:00:00') 
          )
          A IF (EXISTS 
          (
            SELECT
              * 
            FROM
              INFORMATION_SCHEMA.TABLES 
            WHERE
              TABLE_SCHEMA = 'DWSAP' 
              AND TABLE_NAME = 'RevRecShipVolProcessed'
          )
) 
          BEGIN
            INSERT INTO
              [DWSAP].[RevRecShipVolProcessed] 
              SELECT
                * 
              FROM
                #TEMP_REVREC 
          END
          ELSE
            BEGIN
              SELECT
                * INTO [DWSAP].[RevRecShipVolProcessed] 
              FROM
                #TEMP_REVREC 
            END
            --The above statement checks that the table "RevRecShipVolProcessed" is present in the Datawarehouse or not,
            -- if present than inserts the incremental data present in Temp_revrec table,
            -- or else Create the table based on all the data present in temp table.
            DROP TABLE #TEMP_REVREC 						-- Once this proc executes than drop this temp table.
            -- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Delete', @rc = @RowsUpdated out
            -- exec CTRL.GetLastRowCount @Label = 'DWTOPS.LoadFactLotHistory_Insert', @rc = @RowsInserted out
            SELECT
              @ROWSINSERTED - @ROWSUPDATED AS ROWSINSERTED,
              @ROWSUPDATED AS ROWSUPDATED 

;WITH CTE AS (
SELECT ROW_NUMBER() 
OVER(Partition By
[PROFITCENTER],[ORDERNUMBER],[PARTNUMBER],[DOCUMENTTYPE],[INVOICEDATE],[COUNT],[FISCAL VARIANT],[FILEYN],[SEGMENT],[VOLUME SEGMENT],[VOLUME SUB-SEGMENT],[COST ELEMENT],[PROCESS NAME],[TREATMENTLOCATION],[TREATINGDOCTOR],[CERTIFICATIONDATE],[CERTIFICATIONYEAR],[ADVANTAGETIER],[PROFESSIONALCATEGORY],[COUNTRY],[COUNTRYGROUP],[REGIONPC],[REGIONGROUP],[GLOBALREGION],[BUSINESS SEGMENT],[DELIVERY],[PRODUCT HIERARCHY],[VOLUME],[VOLUME UNIT],[SHIP-TO PARTY],[SOLD-TO PARTY],[NET WEIGHT],[TOTAL WEIGHT],[SALES ORGANIZATION],[SHIPMENT DATE],[Serial Number],[Initiator Company ID],[DIVISION],[CONTROLLING AREA],[MATERIAL NUMBER],[DELIVERY QUANTITY],[ITEM CATEGORY],[SALESORDER ITEM],[TOTAL QUANTITY],[DELIVERABLE QUANTITY],[TREATMENT CATEGORY],[DELIVERABLE TYPE],[AGE TIER],[ORDER QUANTITY],[DELIVERABLE CATEGORY],[COMPLIANCE INDICATOR],[VOLUMEFLAG],[REPORTING CHANNEL],[PLANT],[DELIVERYITEM]
Order By
[PROFITCENTER],[ORDERNUMBER],[PARTNUMBER],[DOCUMENTTYPE],[INVOICEDATE],[COUNT],[FISCAL VARIANT],[FILEYN],[SEGMENT],[VOLUME SEGMENT],[VOLUME SUB-SEGMENT],[COST ELEMENT],[PROCESS NAME],[TREATMENTLOCATION],[TREATINGDOCTOR],[CERTIFICATIONDATE],[CERTIFICATIONYEAR],[ADVANTAGETIER],[PROFESSIONALCATEGORY],[COUNTRY],[COUNTRYGROUP],[REGIONPC],[REGIONGROUP],[GLOBALREGION],[BUSINESS SEGMENT],[DELIVERY],[PRODUCT HIERARCHY],[VOLUME],[VOLUME UNIT],[SHIP-TO PARTY],[SOLD-TO PARTY],[NET WEIGHT],[TOTAL WEIGHT],[SALES ORGANIZATION],[SHIPMENT DATE],[Serial Number],[Initiator Company ID],[DIVISION],[CONTROLLING AREA],[MATERIAL NUMBER],[DELIVERY QUANTITY],[ITEM CATEGORY],[SALESORDER ITEM],[TOTAL QUANTITY],[DELIVERABLE QUANTITY],[TREATMENT CATEGORY],[DELIVERABLE TYPE],[AGE TIER],[ORDER QUANTITY],[DELIVERABLE CATEGORY],[COMPLIANCE INDICATOR],[VOLUMEFLAG],[REPORTING CHANNEL],[PLANT],[DELIVERYITEM]) AS [ROW],
[PROFITCENTER],[ORDERNUMBER],[PARTNUMBER],[DOCUMENTTYPE],[INVOICEDATE],[COUNT],[FISCAL VARIANT],[FILEYN],[SEGMENT],[VOLUME SEGMENT],[VOLUME SUB-SEGMENT],[COST ELEMENT],[PROCESS NAME],[TREATMENTLOCATION],[TREATINGDOCTOR],[CERTIFICATIONDATE],[CERTIFICATIONYEAR],[ADVANTAGETIER],[PROFESSIONALCATEGORY],[COUNTRY],[COUNTRYGROUP],[REGIONPC],[REGIONGROUP],[GLOBALREGION],[BUSINESS SEGMENT],[DELIVERY],[PRODUCT HIERARCHY],[VOLUME],[VOLUME UNIT],[SHIP-TO PARTY],[SOLD-TO PARTY],[NET WEIGHT],[TOTAL WEIGHT],[SALES ORGANIZATION],[SHIPMENT DATE],[Serial Number],[Initiator Company ID],[DIVISION],[CONTROLLING AREA],[MATERIAL NUMBER],[DELIVERY QUANTITY],[ITEM CATEGORY],[SALESORDER ITEM],[TOTAL QUANTITY],[DELIVERABLE QUANTITY],[TREATMENT CATEGORY],[DELIVERABLE TYPE],[AGE TIER],[ORDER QUANTITY],[DELIVERABLE CATEGORY],[COMPLIANCE INDICATOR],[VOLUMEFLAG],[REPORTING CHANNEL],[PLANT],[DELIVERYITEM]
From DWSAP.[RevRecShipVolProcessed] 
WITH(NOLOCK) )
DELETE FROM CTE WHERE [ROW]>1

    END

