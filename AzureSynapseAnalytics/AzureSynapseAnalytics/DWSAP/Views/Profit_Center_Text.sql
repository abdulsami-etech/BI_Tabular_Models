CREATE VIEW [DWSAP].[Profit_Center_Text]
AS SELECT cepct.[PRCTR], 
 CASE WHEN cepct .LTEXT = '' THEN cepct .KTEXT
 ELSE cepct .LTEXT END as [Text]
 FROM SrcSAP.CEPCT  cepct WHERE cepct .SPRAS = 'E';