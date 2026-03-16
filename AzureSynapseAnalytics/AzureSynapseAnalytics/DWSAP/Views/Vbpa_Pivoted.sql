CREATE VIEW [DWSAP].[VBPA_Pivoted] AS SELECT *
FROM
(
    SELECT [VBELN],
           [PARVW],
           [KUNNR]
    FROM [SrcSAP].[VBPA]
) AS SourceTable PIVOT(MAX([KUNNR]) FOR [PARVW] IN([WE],
                                                         [RG],
                                                         [RE],
                                                         [AG], [ZE])) AS PivotTable;