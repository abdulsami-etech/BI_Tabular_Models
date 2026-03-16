CREATE PROC [DWSAP].[LoadDeltaCopaTransformations] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS 

DECLARE @lastdatetime AS datetime2;
-- Here we are getting the max timestamp to filter just the newly inserted and updated table in the base tables 
-- if our Processed table is empty we make the timestamp to be 1900 so that all of the data is processed this gives 
-- us the ability handle both Full Loads and Delta Loads
IF (EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'DWSAP'
                 AND  TABLE_NAME = 'FactCOPATranspose'))
			BEGIN
	SET @lastdatetime = (SELECT ISNULL(MAX(ADLSTimestamp),'1900-12-31 00:00:00') FROM DWSAP.FactCOPATranspose)
	END
	ELSE
	BEGIN
	SET @lastdatetime = '1900-12-31 00:00:00'
	END
		-- Here we are checking if the Table already exists within the Data Warehouse or not
		-- Because if the table doesn't exist the code will give an error
		IF (EXISTS (SELECT *
                 FROM INFORMATION_SCHEMA.TABLES
                 WHERE TABLE_SCHEMA = 'DWSAP'
                 AND  TABLE_NAME = 'FactCOPATranspose'))
			BEGIN
					-- We begin the transaction here to handle the upserts
					-- The common data would be deleted and then it would be re-inserted
					BEGIN TRANSACTION;				
						-- This is the Delete Query that is responsible for 
						-- deleting the common data
						-- There is a join happenning between Item Number Document Number and Currency Type
						DELETE  DWSAP.FactCOPATranspose
						FROM DWSAP.FactCOPATranspose
						INNER JOIN SrcSAP.CE110US
						ON
						(DWSAP.FactCOPATranspose.BELNR =SrcSAP.CE110US.BELNR and
						DWSAP.FactCOPATranspose.POSNR =SrcSAP.CE110US.POSNR  and
						DWSAP.FactCOPATranspose.PALEDGER=SrcSAP.CE110US.PALEDGER )
						WHERE SrcSAP.CE110US.ADLSTimestamp>@lastdatetime
						-- After the Deletes we are going to insert all the data on the basis of the timestamp 
						-- This insert statement has a lot of transformations, it also has some columns from VBAP to avoid 
						-- joining of the columns again 
						INSERT INTO DWSAP.FactCOPATranspose
						(LZBatchID,ADLSTimestamp,MANDT,PALEDGER,CURTP,VRGAR,VERSI,PERIO,PAOBJNR,PASUBNR,BELNR,POSNR,
						HZDAT,USNAM,GJAHR,PERDE,WADAT,FADAT,BUDAT,ALTPERIO,PAPAOBJNR,PAPASUBNR,KNDNR,ARTNR,FKART,FRWAE,KURSF,KURSBK,
						KURSKZ,REC_WAERS,KAUFN,KDPOS,[OGKAUFN],[OGKDPOS],RKAUFNR,SKOST,PRZNR,BUKRS,KOKRS,WERKS,GSBER,VKORG,VTWEG,SPART,HRKFT,PLIKZ,KSTAR,
						PSPNR,KSTRG,RBELN,RPOSN,STO_BELNR,STO_POSNR,PRCTR,PPRCTR,RKESTATU,TIMESTMP,COPA_AWTYP,COPA_AWORG,COPA_BWZPT,
						COPA_AWSYS,BESKZ,KDGRP,KUNRE,KUNWE,LAND1,PSTYV,VKBUR,VRTNR,WWCST,WWCH2,WWSIZ,WWICI,COPA_KOSTL,PRODH,VKGRP,
						WW010,WW021,WW022,PLTYP,MATKL,BZIRK,WW023,KVGR1,KVGR2,WW015,WW025,WWA01,WWA02,AUART,WW027,WW028,WWFT1,WWFT2,
						WWFT3,WWFT4,WWFT5,WWFT6,WWFT7,WWFT8,WWFT9,AUGRU,ABGRU,ABSMG_ME,ABSMG,ERLOS,KWKDRB,KWMARB,MRABA,KWMKPR,VVFGS,
						RABAT,KWSKTO,ValueField,ColumnValue,DWBatchID,ZPROCESS,BUSSEGMNT,SPRAS,vbapWERKS,vbapPSTYV,vbapZZDELI_TYPE,
						DDTEXT,LTEXT,IncentiveName,[vbapMVGR1],[vbapMVGR2],[vbapMVGR3],[vbapMVGR4],[vbapMVGR5],[vbapVRKME],[vbapVOLEH],
						[vbapGEWEI],[vbapZZTREAT_OPT],[vbapZZTREV_DATE],[vbapMEINS],[vbapLGORT],[vbapMATNR],[Free_Paid])
						SELECT
						un.LZBatchID,un.ADLSTimestamp,MANDT,PALEDGER,CURTP,VRGAR,VERSI,PERIO,PAOBJNR,PASUBNR,BELNR,POSNR,
						HZDAT,USNAM,GJAHR,PERDE,WADAT,FADAT,BUDAT,ALTPERIO,PAPAOBJNR,PAPASUBNR,KNDNR,ARTNR,FKART,FRWAE,KURSF,
						KURSBK,KURSKZ,REC_WAERS,KAUFN,KDPOS,[OGKAUFN],[OGKDPOS],RKAUFNR,SKOST,PRZNR,BUKRS,KOKRS,WERKS, GSBER,VKORG,VTWEG,SPART,HRKFT,
						PLIKZ,KSTAR,PSPNR,KSTRG,RBELN,RPOSN,STO_BELNR,STO_POSNR,PRCTR,PPRCTR,RKESTATU,TIMESTMP,COPA_AWTYP,COPA_AWORG,
						COPA_BWZPT,COPA_AWSYS,BESKZ,KDGRP,KUNRE,KUNWE,LAND1,COALESCE (PSTYV,vbapPSTYV)as PSTYV,VKBUR,VRTNR,WWCST,WWCH2,WWSIZ,WWICI,COPA_KOSTL,
						 PRODH,VKGRP,WW010,WW021,WW022,PLTYP,MATKL,BZIRK,WW023,KVGR1,KVGR2, WW015,WW025,WWA01,WWA02,AUART,WW027,WW028,
						WWFT1,WWFT2,WWFT3,WWFT4,WWFT5,WWFT6,WWFT7,WWFT8,WWFT9,AUGRU,ABGRU,ABSMG_ME,ABSMG,ERLOS,KWKDRB,KWMARB,MRABA,
						KWMKPR,VVFGS,RABAT,KWSKTO, ValueField,
						CASE
							-- This is the sign flip transformation that we do for select value fields where data period is NA
							WHEN valuefield.Sign_Flip = 'Yes' AND valuefield.Date_Period = 'No' THEN (-1)*(ColumnValue)
							-- This is the sign flip transformation that we do for select value fields where data period is Applied
							WHEN valuefield.Date_Period = 'Yes' AND BUDAT > valuefield.Date_From AND BUDAT <= valuefield.Date_To AND KAUFN <> '' THEN (-1)*(ColumnValue)
							-- This is the currency transformation that is relevant for 10 Currency Types
							--WHEN tx.CURRDEC = 0 and [CURTP] = '10' then 100 * ColumnValue
						ELSE
							ColumnValue
						END [ColumnValue],@BatchID [DWBatchID], valuefield.Value_Field_Type as [ZPROCESS],[BUSSEGMNT],SPRAS,
            vbapWERKS,vbapPSTYV,vbapZZDELI_TYPE,DDTEXT,LTEXT,IncentiveName,[vbapMVGR1],[vbapMVGR2],[vbapMVGR3],[vbapMVGR4],[vbapMVGR5],[vbapVRKME],[vbapVOLEH],
									[vbapGEWEI],[vbapZZTREAT_OPT],[vbapZZTREV_DATE],[vbapMEINS],[vbapLGORT],[vbapMATNR],[Free_Paid]
						FROM (
							SELECT
									LZBatchID,ADLSTimestamp,MANDT,PALEDGER,CURTP,VRGAR,VERSI,PERIO,PAOBJNR,PASUBNR,BELNR,POSNR,
									HZDAT,USNAM,GJAHR,PERDE,WADAT,FADAT,BUDAT,ALTPERIO,PAPAOBJNR,PAPASUBNR,KNDNR,ARTNR,FKART,FRWAE,KURSF,
									KURSBK,KURSKZ,REC_WAERS,KAUFN,KDPOS,[OGKAUFN],[OGKDPOS],RKAUFNR,SKOST,PRZNR,BUKRS,KOKRS,WERKS, GSBER,VKORG,VTWEG,SPART,HRKFT,
									PLIKZ,KSTAR,PSPNR,KSTRG,RBELN,RPOSN,STO_BELNR,STO_POSNR,PRCTR,PPRCTR,RKESTATU,TIMESTMP,COPA_AWTYP,COPA_AWORG,
									COPA_BWZPT,COPA_AWSYS,BESKZ,KDGRP,KUNRE,KUNWE,LAND1,PSTYV,VKBUR,VRTNR,WWCST,WWCH2,WWSIZ,WWICI,COPA_KOSTL,
									 PRODH,VKGRP,WW010,WW021,WW022,PLTYP,MATKL,BZIRK,WW023,KVGR1,KVGR2, WW015,WW025,WWA01,WWA02,AUART,WW027,WW028,
									WWFT1,WWFT2,WWFT3,WWFT4,WWFT5,WWFT6,WWFT7,WWFT8,WWFT9,AUGRU,ABGRU,ABSMG_ME,ABSMG,ERLOS,KWKDRB,KWMARB,MRABA,
									KWMKPR,VVFGS,RABAT,KWSKTO,Col AS ValueField,
									CASE WHEN CURRDEC = 0 and [CURTP] = '10' then 100 * H.ColumnValue
									ELSE
									H.ColumnValue
									end as ColumnValue 
								,[BUSSEGMNT],SPRAS,vbapWERKS,vbapPSTYV,vbapZZDELI_TYPE,
									DDTEXT,LTEXT,IncentiveName,  [vbapMVGR1],[vbapMVGR2],[vbapMVGR3],[vbapMVGR4],[vbapMVGR5],[vbapVRKME],[vbapVOLEH],
									[vbapGEWEI],[vbapZZTREAT_OPT],[vbapZZTREV_DATE],[vbapMEINS],[vbapLGORT],[vbapMATNR],[Free_Paid]
							   --INTO DWSAP.#Transpose The Below Select is also doing LTRIM for handling the 9 Digit Sales Orders
									FROM (SELECT
							ce11.LZBatchID,ce11.ADLSTimestamp,ce11.MANDT,ce11.PALEDGER,[SrcSAP].[TKEL].CURTP,VRGAR,VERSI,PERIO,ce11.PAOBJNR,PASUBNR,BELNR,ce11.POSNR,
							HZDAT,USNAM,GJAHR,PERDE,WADAT,FADAT,BUDAT,ALTPERIO,PAPAOBJNR,PAPASUBNR,KNDNR,ARTNR,FKART,FRWAE,KURSF,
							KURSBK,KURSKZ,REC_WAERS,replace(ltrim(replace(KAUFN,'0',' ')),' ','0')  as KAUFN,
							replace(ltrim(replace(KDPOS ,'0',' ')),' ','0') as KDPOS,KAUFN as [OGKAUFN], KDPOS as [OGKDPOS],
							RKAUFNR,SKOST,PRZNR,BUKRS,ce11.KOKRS,ce11.WERKS,
							ce11.GSBER,ce11.VKORG,ce11.VTWEG,ce11.SPART,HRKFT,
							PLIKZ,KSTAR,PSPNR,KSTRG,RBELN,RPOSN,STO_BELNR,STO_POSNR,ce11.PRCTR,PPRCTR,RKESTATU,TIMESTMP,COPA_AWTYP,COPA_AWORG,
							COPA_BWZPT,COPA_AWSYS,BESKZ,KDGRP,KUNRE,KUNWE,LAND1,ce11.PSTYV,ce11.VKBUR,VRTNR,WWCST,WWCH2,WWSIZ,WWICI,COPA_KOSTL,
							CASE
								--Here we are checking the Product Hierarchy for Clear Aligner Business Segment
								WHEN ce11.PRODH LIKE 'A1A1%' THEN 'CLEAR ALIGNER'
								--Here we are checking the Product Hierarchy for Itero Business Segment
								WHEN ce11.PRODH LIKE 'A1S1%' THEN 'ITERO'
							END [BUSSEGMNT],'E' as SPRAS,
							-- Here we are again checking some product hierarchies and updating it to the respective ones
							CASE WHEN ce11.PRODH = 'A1A1T1C2R101' AND PERIO <= '2018001' THEN 'A1A1T1C2R1'
							-- Here we are again checking some product hierarchies and updating it to the respective ones
							WHEN ce11.PRODH = 'A1A1T1C2L103' AND PERIO <= '2018001' THEN 'A1A1T1C2G1'
										WHEN ce11.PRODH = 'A1A1N102' AND PERIO < '2017001' AND vbap.MATNR = '000000000000109810'  AND (KSTAR = '' OR KSTAR = 0) THEN 'A1A1T1C101'
								  ELSE ce11.PRODH
								  END [PRODH],ce11.VKGRP,WW010,WW021,WW022,PLTYP,ce11.MATKL,BZIRK,WW023,ce11.KVGR1,ce11.KVGR2,

--Has to add Quotes inorder to avoid data conversion error comparing 'Z01' to integer values--
								  CASE WHEN ce11.VTWEG = '20' AND WW015 = '00' THEN '21'
								  -- Reporting Channel Transformations are happening here 
								   WHEN ce11.KVGR1 = '1' AND WW015 = '00' AND ce11.VTWEG = '10' THEN '11'
								   WHEN ce11.KVGR1 = '2' AND WW015 = '00' AND ce11.VTWEG = '10' THEN '12'
								   WHEN ce11.KVGR1 = '3' AND WW015 = '00' AND ce11.VTWEG = '10' THEN '13'
								   --WHEN ce11.PRODH LIKE 'A1S1%' AND ce11.WW015 = '00' AND vbap.MVGR5 = 'Z3' THEN '11'
								   WHEN ce11.PRODH = 'A1A1T1C10301' AND WW015 = '00' THEN '11'
								   --WHEN WW015 = '00' THEN '12'
								  ELSE WW015
								  END [WW015],

----End comments
								  TRY_CAST([WW025] AS DECIMAL(10,3)) AS [WW025], TRY_CAST([WWA01] AS DECIMAL(10,3)) AS [WWA01],TRY_CAST([WWA02] AS DECIMAL(10,3)) AS [WWA02],
								  ce11.AUART,WW027,WW028,WWFT1,WWFT2,WWFT3,WWFT4,WWFT5,WWFT6,WWFT7,WWFT8,WWFT9,ce11.AUGRU,ce11.ABGRU,ABSMG_ME,ABSMG,ERLOS,KWKDRB,KWMARB,MRABA,
							KWMKPR,VVFGS,RABAT,KWSKTO,[VV074],[VV081],[VV069],[VV022],[VV075],[VV076],[VV020],[VV060],[VV073],[VV059],
							[VV023],[VVR21],[VV014],[VV068],[VV016],[VV021],[VV019],[VV061],[VV010],[VV064],[VV062],[VV015],[VVG21],
							[VV011],[VV057],[VV036],[VV012],[VV066],[VV067],[VV070],[VV071],[VV063],[VV056],[VV058],[VV065],[VV024],[VV013],
							[VVD21],vbap.WERKS as [vbapWERKS], vbap.PSTYV as vbapPSTYV, 
							case when vbap.ZZDELI_TYPE = '' then NULL else vbap.ZZDELI_TYPE end as [vbapZZDELI_TYPE],ctext.[DDTEXT], ct.LTEXT,
  							dic.IncentiveName,vbap.MVGR1 as [vbapMVGR1] , vbap.MVGR2 as [vbapMVGR2], vbap.MVGR3  as [vbapMVGR3], vbap.MVGR4 as [vbapMVGR4], vbap.MVGR5  as [vbapMVGR5],
  							vbap.VRKME as [vbapVRKME], vbap.VOLEH as [vbapVOLEH],vbap.GEWEI  as [vbapGEWEI], vbap.ZZTREAT_OPT  as [vbapZZTREAT_OPT], vbap.ZZTREV_DATE as [vbapZZTREV_DATE],
  							vbap.MEINS as [vbapMEINS], vbap.LGORT  as [vbapLGORT],vbap.MATNR  as [vbapMATNR]
  							-- Free Paid Logic is being Derived Here
  							,case when vbak.[ZZDELI_CATE] = 'Primary' then 'Paid'
							 when vbak.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))
							 and vbap.[ZZFRE_QTY] = 0 then 'Paid'
							 when vbak.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
							 and vbap.[ZZFRE_QTY] = vbap.[ZZTOT_QTY] then 'Free'
							 when vbak.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
							 and (vbap.[ZZTOT_QTY] - vbap.[ZZFRE_QTY]) > 0   then 'Paid'
							 when vbak.[ZZDELI_CATE] = 'Secondary' AND ZZDELI_TYPE IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY'))  
							 and (vbap.[ZZTOT_QTY] - vbap.[ZZFRE_QTY]) < 0   then 'Error'
							 when vbak.[ZZDELI_CATE] = 'Secondary'  AND ZZDELI_TYPE NOT IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
							 vbap.[PRODH] LIKE 'A1A1%' AND vbap.[NETPR] = '0.00' THEN 'Free'
							 when vbak.[ZZDELI_CATE] = 'Secondary'  AND ZZDELI_TYPE NOT IN 
							 (SELECT OPERAND1 FROM [SrcSAPFile].[VolumeConfig] WHERE [NAME] IN ('DELV_TYPE_FOC','DELV_TYPE_DELV_QTY')) AND 
							 vbap.[PRODH] LIKE 'A1A1%' AND vbap.[NETPR] <> '0.00' THEN 'Paid'
							 when vbak.[ZZDELI_CATE] ='' AND vbap.[PRODH] LIKE 'A1S1U1%' THEN 'Paid'
							 when vbak.[ZZDELI_CATE] ='' AND vbap.[PRODH] LIKE 'A1S1U2%' AND vbap.[NETPR] = '0.00' THEN 'Free'
							 when vbak.[ZZDELI_CATE] ='' AND vbap.[PRODH] LIKE 'A1S1U2%' AND vbap.[NETPR] <> '0.00' THEN 'Paid' 
							 end [Free_Paid],tx.CURRDEC
							FROM SrcSAP.CE110US ce11
								INNER JOIN [SrcSAP].[TKEL]
										ON ce11.PALEDGER = [SrcSAP].[TKEL].PALEDGER
										LEFT  JOIN SrcSAP.VBAP vbap
										ON vbap.VBELN = ce11.KAUFN AND vbap.POSNR = ce11.KDPOS
										LEFT JOIN SrcSAP.VBAK vbak 
										on vbak.VBELN = ce11.KAUFN
										INNER JOIN SrcSAP.CKMLCUR ctext on ctext.CURTP  = [SrcSAP].[TKEL].CURTP and  ctext.SPRSL = 'E'
										INNER JOIN SrcSAP.TCURT ct on ct.WAERS  = ce11.REC_WAERS and ct.SPRAS = 'E'
										LEFT  JOIN  TABSAP.[DimIncetiveCodeDesc] dic on dic.SAPOrderNumber  = ce11.KAUFN AND  ce11.wwft1= Apttus_Config2__IncentiveCode__c
										LEFT  JOIN  SrcSAP.TCURX tx on tx.CURRKEY = ce11.[REC_WAERS]
										WHERE  ce11.ADLSTimestamp > @lastdatetime
										--AND ce11.KAUFN in ('0060021119', '0060005455', '0060005462', '00287688766')
										
										

							) AS cp

						UNPIVOT
						(
						 ColumnValue FOR Col IN ([VV074],[VV081],[VV069],[VV022],[VV075],[VV076],[VV020],[VV060],[VV073],[VV059],
							[VV023],[VVR21],[VV014],[VV068],[VV016],[VV021],[VV019],[VV061],[VV010],[VV064],[VV062],[VV015],[VVG21],
							[VV011],[VV057],[VV036],[VV012],[VV066],[VV067],[VV070],[VV071],[VV063],[VV056],[VV058],[VV065],[VV024],[VV013],
							[VVD21])
						) AS H
						WHERE H.ColumnValue <> 0
									 AND VRGAR <> char(65)) as un
									 LEFT JOIN DWSAP.ConfigCOPATransformations valuefield on
									  un.ValueField = valuefield.Value_Field
									  -- In the above statements we are also doing the unpivot that is responsible for Transpose Operations 
									  -- Other than that we also check some other conditions such as Record Type not being equal to A
									  -- Also we only pick the non zero ones
									  PRINT('Records inserted into the table')
									  -- We are updating the Reporting Channel in the Below update statement
									  	UPDATE DWSAP.FactCOPATranspose
										SET
											WW015 = CASE
													WHEN MVGR5 = 'Z3' THEN 11
													ELSE 12
													END
											FROM SrcSAP.VBAP
										WHERE DWSAP.FactCOPATranspose.OGKAUFN = SrcSAP.VBAP.VBELN
											   AND DWSAP.FactCOPATranspose.PRODH LIKE 'A1S1%'
											   AND DWSAP.FactCOPATranspose.WW015 = 00
										PRINT('Reporting Channel is SET to 11')
										
										-- Also we only pick the non zero ones
	
										UPDATE DWSAP.FactCOPATranspose
									    SET WW015 = 12
									    WHERE WW015 = 00
									    PRINT('Reporting Channel is SET to 12')
									  
									  
						COMMIT;
						END;;
