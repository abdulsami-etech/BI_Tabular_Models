CREATE VIEW [TABSAP].[DimTreatmentOption]
AS SELECT                     [TreatmentOptionKey] [TreatmentOpt Key]
                              ,[SAPTreatmentOption] [SAP Treatment Option]
                              ,[TreatmentOption] [Treatment Option]
                              ,[SortOrder] [Sort Order]
                              ,[ProductHierarchy] [Product Hierarchy]
                              ,[TreatmentOptionHighLevel] [Treatment Option High Level]
                              ,[TreatmentOptionReportingLevel] [Treatment Option Reporting Level]
FROM [SrcSAPFile].[TreatmentOption];