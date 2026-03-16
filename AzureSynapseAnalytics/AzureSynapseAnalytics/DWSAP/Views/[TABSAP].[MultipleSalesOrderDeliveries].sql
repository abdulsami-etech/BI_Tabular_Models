--BI-12996 Alter View
Alter VIEW [TABSAP].[MultipleSalesOrderDeliveries] AS 
SELECT 
  COUNT ([DeliveryKey]) AS [Count], 
  [Sales Order Key] 
FROM 
  (
    SELECT 
      lips.VBELN AS [Delivery], 
      CONCAT(lips.VBELN, lips.POSNR) AS [DeliveryKey], 
      likp.WADAT_IST AS [Shipment Date], 
      CONCAT(lips.VGBEL, '/', lips.[VGPOS]) AS [Sales Order Key] 
    FROM 
      SrcSAP.LIKP likp 
      inner join srcsap.LIPS lips on likp.VBELN = lips.VBELN 
    WHERE 
      likp.WADAT_IST <> '00000000' 
      AND --JIRA NUMBER // BI-11264
      CONCAT(lips.VBELN, '/', lips.POSNR) NOT IN (
        SELECT 
          CONCAT (
            [OBJECTID], 
            '/', 
            RIGHT (TABKEY, 6)
          ) AS Item 
        FROM 
          SrcSAP.ZVOTC_CDHDR_POS1 zcp 
        WHERE 
          zcp.CHNGIND = 'D' 
          AND TABNAME = 'LIPS'
      )
  ) ac 
GROUP BY 
  [Sales Order Key] 
HAVING 
  COUNT([DeliveryKey])> 1;
