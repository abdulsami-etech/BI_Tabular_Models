--BI-12996 New procedure
CREATE PROC [DWSAP].[FACTShipmentDeleteIndicatorData_Performance] AS DECLARE @DATE DATE = GETDATE();
--creating the procedure to check the 'D' and 'I' indicator
with CTE as(
--concatenating the objectid and tabkey column to achieve the Sals column 
SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (RIGHT (TABKEY, 6) AS int)
    ) AS Sals, 
    UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
--checking for the Change indicator "D" and table name condition
  WHERE 
    zcp.CHNGIND = 'D' 
    ANd TABNAME = 'VBAP'
), 
CTE2 AS(
--concatenating the objectid and tabkey column to achieve the Sals column 
  SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int)
    ) AS Sals, 
    UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
--checking for the Change indicator "I" and "U" indicator and table name condition
  WHERE 
    zcp.CHNGIND IN ('I', 'U') 
    ANd TABNAME = 'VBAP'
) 
--updating the table with deleteFlag 0 and adlstimestamp with current date
UPDATE 
  [DWSAP].[FactShipments_Materialized_Performance] 
SET 
  [Delete Flag] = 0, 
  [ADLSTimestamp] = GETDATE() 
WHERE 
  CONCAT (
    [Sales Order Number], '/', [Sales Order Item Number]
	)IN(
    SELECT 
      A.Sals 
    FROM 
      CTE A 
    WHERE 
      A.Sals NOT IN(
        SELECT 
          Sals 
        from 
          CTE2
      )
  ) 
  AND [Delete Flag] IS NULL ----Checking Deleted Orders and Items in FactShipments_Materialized 
  ----When [DeliveryNumber] has both (CHNGIND= 'D' or CHNGIND= 'I') but D.UDATE>I.UDATE
  ;
with CTE as(
--concatenating the objectid and tabkey column to achieve the Sals column 
  SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ),
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    ) AS Sals, 
    MAX(UDATE) UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
--checking for the Change indicator "D" indicator and table name condition
  WHERE 
    zcp.CHNGIND = 'D' 
    ANd TABNAME = 'VBAP' 
  GROUP BY 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    )
), 
CTE2 AS(
  SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    ) AS Sals, 
    MAX(UDATE) UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
  WHERE 
    zcp.CHNGIND IN ('I', 'U') 
    ANd TABNAME = 'VBAP' 
  GROUP BY 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    )
) 
UPDATE 
  [DWSAP].[FactShipments_Materialized_Performance] 
SET 
  [Delete Flag] = 0, 
  [ADLSTimestamp] = GETDATE() 
WHERE 
  CONCAT (
    [Sales Order Number], '/', [Sales Order Item Number]
  ) IN(
    SELECT 
      A.Sals 
    FROM 
      CTE A 
      JOIN CTE2 B ON A.Sals = B.Sals 
      AND A.UDATE > B.UDATE
  ) 
  AND [Delete Flag] IS NULL;
with CTE as(
  SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    ) AS Sals, 
    MAX(UDATE) UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
  WHERE 
    zcp.CHNGIND = 'D' 
    ANd TABNAME = 'VBAP' 
  GROUP BY 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    )
), 
CTE2 AS(
  SELECT 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    ) AS Sals, 
    MAX(UDATE) UDATE 
  FROM 
    SrcSAP.ZVOTC_CDHDR_POS1 zcp 
  WHERE 
    zcp.CHNGIND IN ('I', 'U') 
    ANd TABNAME = 'VBAP' 
  GROUP BY 
    CONCAT (
      REPLACE(
        LTRIM(
          REPLACE(OBJECTID, '0', ' ')
        ), 
        ' ', 
        '0'
      ), 
      '/', 
      CAST (
        RIGHT (TABKEY, 6) AS int
      )
    )
), 
CTE3 AS(
  SELECT 
    A.Sals 
  FROM 
    CTE A 
    JOIN CTE2 B ON A.Sals = B.Sals 
    AND A.UDATE = B.UDATE
) 
--updating the table with deleteFlag 0 and adlstimestamp with current date where Salesordernumber not available in docNumber column of scanner history file
UPDATE 
  [DWSAP].[FactShipments_Materialized_Performance] 
SET 
  [Delete Flag] = 0, 
  [ADLSTimestamp] = GETDATE() 
WHERE 
  [Sales Order Number] NOT IN (
    SELECT 
      [DOC_NUMBER] 
    FROM 
      [SrcSAPFile].[ScannerHistory]
  ) 
  AND CONCAT (
    [Sales Order Number], '/', [Sales Order Item Number]
  ) IN (
    SELECT 
      Sals 
    FROM 
      CTE3 
    WHERE 
      Sals NOT IN(
        SELECT 
          DISTINCT CONCAT(
            CONVERT(BIGINT, VBELN), 
            '/', 
            CONVERT(BIGINT, POSNR)
          ) 
        From 
          SrcSAP.VBAP
      )
  ) 
  AND [Delete Flag] IS NULL
