CREATE VIEW [TABIRIS].[SalesContracts] AS select 
	   sc.[TicketNumber]
	  ,da.[AccountNumber]
	  ,sc.[OpportunityNumber]
      ,isnull(sc.[Opp_Contract_Date],sc.[Ticket_Contract_Date]) as [Contract_Signed_Date]
	  ,isnull(sc.[Opp_Ship_Date],sc.[Ticket_Ship_Date]) as [Contract_Shipment_Date]
	  ,coalesce(sc.[OplQuantity],sc.[Opp_Qty],sc.[Ticket_Qty],1) as [Scanner Quantity]
	  ,sc.[Opp_StageName]

	  ,sc.[Opp_Cancellation_Date]
	  ,sc.[Opp_Purchase_Price] as [Opp_Sales_Type]
	  ,case 
			when sc.[Opp_Purchase_Price] like '%demo%' then 'Demo'
			when sc.[Opp_StageName] like '%canc%' or sc.Ticket_Cancellation_received = '1' or isnull(sc.Opp_Cancellation_Date,'') <> '' then 'Cancelled'
			when sc.Opp_Purchase_Price like '%Go Digital%' then 'Go Digital'
			when sc.Ticket_Purchase_Price = 0 then 'Zero Price'
			when sc.Opp_StageName like 'close%' then 'Lost Sale'  
			when sc.Opp_Purchase_Price = 'Rental' then 'Rental'
			else 'Actual Sale'
	   end as [Sale Status]
	  ,coalesce(sc.[ProductName],sc.[Opp_Product_option],sc.[Ticket_Scanner_Model],sc.[Opp_iTero_Type]) as [Product Model]
	  ,sc.[Opp_RecordType]
	  ,sc.[ProductFamily]
	  ,sc.[ProductCode]
	  ,sc.Opp_Commission_Date as [Contract_Processed_Date]
	  ,sc.[IsDeleted] as [IsDeleted]
	  ,sc.[Opp_EMEA_Sales_Channel]	
	  ,sc.[Opp_Distributor]
	  ,da.ShippingCountryCode as [Acc_Country_Code]
	  ,CASE 
		WHEN UPPER(LTRIM(RTRIM(sc.[Opp_Promotion]))) = 'NONE' THEN 'No Promo'
		else sc.[Opp_Promotion]
	  end as [Opp_Promotion],
	  sc.OppCloseDate,
	  sc.ContactId as [ContactId],
      sc.IsChildOpportunity
FROM [DWIRIS].[DimSalesContract] sc
  left join DW.DimAccount da
	on da.[SKAccount] = sc.[SKAccount]
where isnull(sc.ProductCode,'') in ('202965','108063','200915','202964','205929','209156',
						 '208481','206160','206855','209176','206856','209157','209155','108064','',
						 '211633','211634','211636','211635',
						 '211483','211484','211485','211490','211491','211492','211898','211899','212933','212934','211376','211378','211572','202962',
'211377','211573','212073','212074')
and Left (isnull(sc.[Opp_Description],''),4)<> 'PLID'
and isnull(sc.[Opp_RecordType],'') <> 'EU Lab'
and isnull(sc.[IsDeleted],0) <> 1;