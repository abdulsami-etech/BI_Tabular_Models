CREATE VIEW [TABSAP].[DimDeliverableType]
AS SELECT                     [DeliverableTypeKey] [Deliverable Type Key]
                              ,[SAPDeliverableType] [SAP Deliverable Type]
                              ,[TreatmentCategory] [Treatment Category]
                              ,[DeliverableTypeName] [Delivery Type]
                              ,[SortOrder] [Sort Order]
                              ,[SapOrderType] [SAP Order Type]
FROM [SrcSAPFile].[DeliverableType]

UNION

select distinct 65 [Deliverable Type Key]
                              ,ZZDELI_TYPE [SAP Deliverable Type]
                              ,null [Treatment Category]
                              ,null [Delivery Type]
                              ,0 [Sort Order]
                              ,null [SAP Order Type]
FROM SrcSAP.VBAP vbap
inner join SrcSAP.VBAK vbak on vbak.VBELN = vbap.VBELN 
where ZZDELI_TYPE not in (select distinct [SAPDeliverableType] FROM [SrcSAPFile].[DeliverableType]);