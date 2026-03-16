CREATE VIEW [TABSAP].[DimGLAccount]
AS SELECT [SrcSAP].[SKB1].[BUKRS]as [Company Code],
[SrcSAP].[SKB1].[SAKNR]as [G/L Account Number],[BEGRU]as [Authorization Group],
[ERDAT]as [Date on which the Record Was Created],[ERNAM]as [Name of Person who Created the Object],
[FIPLS]as [Financial Budget Item],[FSTAG]as [Field status group],[WAERS]as [Account currency],
[RECID]as [Recovery Indicator],[FIPOS]as [Commitment Item],[BEWGP]as [Valuation Group],
CONCAT(BUKRS,',',[SrcSAP].[SKB1].SAKNR) AS GL_ACCNT_KEY
FROM [SrcSAP].[SKB1];