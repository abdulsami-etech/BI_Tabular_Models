CREATE VIEW [TABTOPS].[FactSAPOrderAlignerCount] AS SELECT --CAST(likp.[wadat_ist]    as date)                                   AS KeyDate, 
       Isnull(CONVERT(INT, CONVERT(VARCHAR(8), likp.[wadat_ist], 112)), -1) AS SKCompleteDate, 
       lips.vkgrp                                                           AS CountryCode, 
       lips.werks                                                           AS Plant, 
       Count(DISTINCT lips.vgbel)                                           AS OrderCount ,
	   SUM(vbap.[ZZTOT_QTY])                                                AS AlignerQuantity,
	   	   CASE 
			WHEN lips.ARKTX like '%Retainer%' 
			THEN 'Retainer'
			ELSE 'Aligner'		END											AS MaterialType,
       'Shipped'                                                            AS EventType

FROM   [SrcSAP].[likp] likp 
       INNER JOIN [SrcSAP].[lips] lips 
               ON lips.[vbeln] = likp.[vbeln] 
       INNER JOIN [SrcSAP].[vbap] vbap 
               ON vbap.[vbeln] = lips.[vgbel] and  vbap.[POSNR] = lips.[VGPOS]
WHERE  lips.ladgr IN ( 'Z001', 'Z002', 'Z004', 'Z005', 'Z006' ) 
--and CONVERT(INT, CONVERT(VARCHAR(8), likp.[wadat_ist], 112)) >= 20210101
GROUP  BY lips.vkgrp,lips.ARKTX,
          -- CAST(likp.[wadat_ist]    as date) , 
          Isnull(CONVERT(INT, CONVERT(VARCHAR(8), likp.[wadat_ist], 112)), -1), lips.werks 

union all

SELECT -- CAST(vbak.[ZZCHECK_IN] as date)                                     AS KeyDate, 
       Isnull(CONVERT(INT, CONVERT(VARCHAR(8), vbak.[ZZCHECK_IN], 112)), -1)AS SKCompleteDate, 
       vbak.vkgrp                                                           AS CountryCode, 
       vbap.werks                                                           AS Plant, 
       Count(DISTINCT vbak.[vbeln])                                         AS OrderRecivedCount ,
	   SUM(vbap.[ZZTOT_QTY])                                                AS AlignerQuantity,
	   	   CASE 
			WHEN vbap.ARKTX like '%Retainer%' 
			THEN 'Retainer'
			ELSE 'Aligner'		END											AS MaterialType,
        'Received'                                                          AS EventType

FROM   [SrcSAP].[vbak]  vbak 
       INNER JOIN [SrcSAP].[vbap] vbap 
               ON vbap.[vbeln] = vbak.[vbeln] 
WHERE  vbap.pstyv IN ( 'Z001', 'Z002', 'Z004', 'Z005', 'Z006' ) 
and   ZZCHECK_IN!='00000000'
--and  CONVERT(INT, CONVERT(VARCHAR(8), vbak.[ZZCHECK_IN], 112)) >= 20210101
GROUP  BY vbak.vkgrp,vbap.ARKTX,
          -- CAST(vbak.[ZZCHECK_IN] as date) , 
          Isnull(CONVERT(INT, CONVERT(VARCHAR(8), vbak.[ZZCHECK_IN], 112)), -1), vbap.werks;