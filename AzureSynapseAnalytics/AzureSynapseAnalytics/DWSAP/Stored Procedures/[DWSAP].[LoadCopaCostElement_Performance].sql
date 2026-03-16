--BI-12996 New procedure
CREATE PROC [DWSAP].[LoadCopaCostElement_Performance] AS 
-- This proc is responsible for processing Blank Cost Element in our Processed Transpose Table 
-- Here we generate a temp table that is responsible for getting the Cost Element along with the Billing Document and
-- the Billing Item Number, we only take the records where the cost element is blank
IF OBJECT_ID('tempdb.#TEMP_COSTELEMENT', 'U') IS NOT NULL 
DROP 
  TABLE #TEMP_COSTELEMENT
Select 
  DISTINCT d.SAKN1, 
  c.VBELN, 
  a.RBELN, 
  a.RPOSN, 
  a.valuefield INTO #TEMP_COSTELEMENT
FROM 
  [DWSAP].[FactCOPATranspose_Performance] a 
  inner join SrcSAP.VBRK c ON c.VBELN = a.RBELN 
  inner join SrcSAP.KONV d ON d.KNUMV = c.KNUMV 
  AND d.SAKN1 <> '' 
  AND a.RPOSN = d.KPOSN 
  inner join [SrcSAP].[T258I] e ON e.KSCHL = d.KSCHL 
  and e.WERTKOMP = a.valuefield 
  INNER JOIN (
    SELECT 
      MAX (KDATU) AS [KDATU], 
      RBELN, 
      RPOSN 
    FROM 
      [DWSAP].[FactCOPATranspose_Performance] a 
      inner join SrcSAP.VBRK c ON c.VBELN = a.RBELN 
      inner join SrcSAP.KONV d ON d.KNUMV = c.KNUMV 
      AND d.SAKN1 <> '' 
      AND a.RPOSN = d.KPOSN 
      inner join [SrcSAP].[T258I] e ON e.KSCHL = d.KSCHL 
      and e.WERTKOMP = a.valuefield 
    WHERE 
      d.SAKN1 <> '' 
      AND a.KSTAR = '' 
    GROUP BY 
      RBELN, 
      RPOSN
  ) a1 on a1.RBELN = a.RBELN 
  and a1.RPOSN = a.RPOSN 
  AND a1.KDATU = d.KDATU 
WHERE 
  a.KSTAR = '' -- the Billing Item Number, we only take the records where the cost element is blank
  -- After generating the Temp Table we update the cost element into the existing Table
UPDATE 
  [DWSAP].[FactCOPATranspose_Performance] 
SET 
  KSTAR = SAKN1 
FROM 
  #TEMP_COSTELEMENT
WHERE 
  [DWSAP].[FactCOPATranspose_Performance].RBELN = #TEMP_COSTELEMENT.RBELN
  AND [DWSAP].[FactCOPATranspose_Performance].RPOSN = #TEMP_COSTELEMENT.RPOSN
  AND [DWSAP].[FactCOPATranspose_Performance].valuefield = #TEMP_COSTELEMENT.valuefield
  -- After updating the Cost Element in the final Processed table we drop the Temp Table
DROP 
  TABLE #TEMP_COSTELEMENT
  -- We again populate the Temp Table this time we do it without a condition that we wAS checked in the earlier condition
  -- Here We don't check the KDATU field and we again only check the Blank Cost Element 
Select 
  DISTINCT d.SAKN1, 
  c.VBELN, 
  a.RBELN, 
  a.RPOSN, 
  a.valuefield INTO #TEMP_COSTELEMENT
FROM 
  [DWSAP].[FactCOPATranspose_Performance] a 
  inner join SrcSAP.VBRK c ON c.VBELN = a.RBELN 
  inner join SrcSAP.KONV d ON d.KNUMV = c.KNUMV 
  AND d.SAKN1 <> '' 
  AND a.RPOSN = d.KPOSN 
  inner join [SrcSAP].[T258I] e ON e.KSCHL = d.KSCHL 
  and e.WERTKOMP = a.valuefield 
WHERE 
  a.KSTAR = '';
-- Again we update the cost element in the main table from the Temp Table
UPDATE 
  [DWSAP].[FactCOPATranspose_Performance] 
SET 
  KSTAR = SAKN1 
FROM 
  #TEMP_COSTELEMENT
WHERE 
  [DWSAP].[FactCOPATranspose_Performance].RBELN = #TEMP_COSTELEMENT.RBELN
  AND [DWSAP].[FactCOPATranspose_Performance].RPOSN = #TEMP_COSTELEMENT.RPOSN
  AND [DWSAP].[FactCOPATranspose_Performance].valuefield = #TEMP_COSTELEMENT.valuefield;;
  -- We finally Drop the Temp Table  
DROP 
  TABLE #TEMP_COSTELEMENT;
