CREATE VIEW [TABSAP].[DimSalesOrganization]
AS SELECT [VKORG] as [Sales Organization],[WAERS] as [Statistics currency],[BUKRS] as [Company code],
			[ADRNR] as [Address],[VKOAU] as [Reference sales org.] ,[KUNNR] as [Customer number],[VKOKL] as [Sales organization calendar],
			[EKORG] as [Purchasing Organization],[EKGRP] as [Purchasing Group],[LIFNR] as [Account Number of Vendor],[WERKS] as [Plant],
			[BSART] as [Order Type] ,[BSTYP] as [Purchasing Document Category],[BWART] as [Movement Type],[LGORT] as [Storage Location],
			[MAXBI] as [Maximum Number of Items],[PLAUFZ] as [Price protection period],[PLAUEZ] as [Unit for price protection]
	FROM [SrcSAP].[TVKO];