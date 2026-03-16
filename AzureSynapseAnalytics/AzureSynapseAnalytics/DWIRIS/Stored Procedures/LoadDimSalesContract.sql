CREATE PROC [DWIRIS].[LoadDimSalesContract] @BatchID [int],@LastSuccessfullDWTimestamp [datetime2](0) AS
begin
set xact_abort on

	declare @RowsInserted	int = 0
		,	@RowsUpdated	int = 0

	if object_id('tempdb..#TempDimSalesContract') is not null
		drop table #TempDimSalesContract

-- Get delta rows
	create table #TempDimSalesContract with (distribution = round_robin, heap) as 
	SELECT 
		
				h.SKSalesContract											as SKSalesContract,
				c.ADLSBatchID,
				c.ADLSTimestamp,
				c.LZBatchID,

				convert(char(40), '')										as DWHash,
				c.ID														as KeySalesContract,
	
				isnull(asseth.SKAsset, -1)									as SKAsset,
				isnull(ah.SKAccount, -1)									as SKAccount,
				isnull(th.SKTeam, -1)										as SKTeam,
				isnull(uh.SKUser, -1)										as SKUser,

				c.Audit_completed_date__c									as AuditCompletedDate,
				YEAR (c.Audit_completed_date__c)*10000+
				MONTH(c.Audit_completed_date__c)*100+
				DAY  (c.Audit_completed_date__c)							as AuditCompletedDateKey,
							
				c.[Manufacturing_Date__c]									as CaseManufacturingDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as CaseManufacturingDateKey,

				convert(datetime2,NULL)/*c.[Contract_Signature_date__c]*/	as ContractSignedDate,
				convert(int,null)/*YEAR (c.[Contract_Signature_date__c])*10000+
				MONTH(c.[Contract_Signature_date__c])*100+		
				DAY  (c.[Contract_Signature_date__c])*/						as ContractSignedDateKey,
	
				c.[Date_First_Contact_Email__c]								as FirstContactEmailDate,
				YEAR (c.[Date_First_Contact_Email__c])*10000+
				MONTH(c.[Date_First_Contact_Email__c])*100+		
				DAY  (c.[Date_First_Contact_Email__c])						as FirstContactEmailDateKey,

				c.[Date_Fourth_Contact__c]									as FourthContactDate,
				YEAR (c.[Date_Fourth_Contact__c])*10000+
				MONTH(c.[Date_Fourth_Contact__c])*100+		
				DAY  (c.[Date_Fourth_Contact__c])							as FourthContactDateKey,
	
				c.[Date_MiM__c]												as MiMDate,
				YEAR (c.[Date_MiM__c])*10000+
				MONTH(c.[Date_MiM__c])*100+		
				DAY  (c.[Date_MiM__c])										as MiMDateKey,

				c.[Date_Notification_Sent_to_Trainer__c]					as NotificationSenttoTrainerDate,
				YEAR (c.[Date_Notification_Sent_to_Trainer__c])*10000+
				MONTH(c.[Date_Notification_Sent_to_Trainer__c])*100+		
				DAY  (c.[Date_Notification_Sent_to_Trainer__c])				as NotificationSenttoTrainerDateKey,	
	
				c.[Date_Third_Contact__c]									as ThirdContactDate,
				YEAR (c.[Date_Third_Contact__c])*10000+
				MONTH(c.[Date_Third_Contact__c])*100+		
				DAY  (c.[Date_Third_Contact__c])							as ThirdContactDateKey,

				c.[Invoice_Date__c]											as InvoiceDate,
				YEAR (c.[Invoice_Date__c])*10000+
				MONTH(c.[Invoice_Date__c])*100+		
				DAY  (c.[Invoice_Date__c])									as InvoiceDateKey,

				convert(datetime2,NULL)										as DimLeasingStatusDate,
				convert(int,NULL)											as DimLeasingStatusDateKey,
	

				c.[Final_Received_Date__c]									as FinalReceivedDate,
				YEAR (c.[Final_Received_Date__c])*10000+
				MONTH(c.[Final_Received_Date__c])*100+		
				DAY  (c.[Final_Received_Date__c])							as FinalReceivedDateKey,

				c.[iTero_Scanner_Rev_Req_Date__c]							as iTeroScannerRevRecDate,
				YEAR (c.[iTero_Scanner_Rev_Req_Date__c])*10000+
				MONTH(c.[iTero_Scanner_Rev_Req_Date__c])*100+		
				DAY  (c.[iTero_Scanner_Rev_Req_Date__c])					as iTeroScannerRevRecDateKey,

				c.[Order_Status__c]											as CaseOrderStatus,
				o.[Order_status__c]											as OpportunityOrderStatus,

				c.[ClosedDate]												as OnboardingDate,
				YEAR (c.[ClosedDate])*10000+
				MONTH(c.[ClosedDate])*100+		
				DAY  (c.[ClosedDate])										as OnboardingDateKey,

				convert(nvarchar(255),null)/*c.[Request_Format__c]*/		as PaymentMethod,

				c.[Processing_completed_date__c]							as ProcessingCompletedDate,
				YEAR (c.[Processing_completed_date__c])*10000+
				MONTH(c.[Processing_completed_date__c])*100+		
				DAY  (c.[Processing_completed_date__c])						as ProcessingCompletedDateKey,

				isnull(o.[Shipped_Date__c],c.[Effective_Shipment_date__c])											as ShippingDate,
				YEAR (isnull(o.[Shipped_Date__c],c.[Effective_Shipment_date__c]))*10000+
				MONTH(isnull(o.[Shipped_Date__c],c.[Effective_Shipment_date__c]))*100+		
				DAY  (isnull(o.[Shipped_Date__c],c.[Effective_Shipment_date__c]))									as ShippingDateKey,

				c.[Manufacturing_Date__c]									as SpareDeliveryDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as SpareDeliveryDateKey,

				c.[VCT_Training_Date__c]									as VCTTrainingDate,
				YEAR (c.[VCT_Training_Date__c])*10000+
				MONTH(c.[VCT_Training_Date__c])*100+		
				DAY  (c.[VCT_Training_Date__c])								as VCTTrainingDateKey,

				convert(decimal(18,2),null)/*c.[Audit_Time_Elapsed__c]*/									as AuditTimeElapsed,
				c.[ProcessingTimeElapsed_V1__c]								as ProcessingTimeElapsed,
				c.[Shipment_Time_Elapsed_V1__c]								as ShipmentTimeElapsed,

				NULL														as ListPrice,  --will be done when Apptus Order and orderlineitem are available
				NULL														as Discount,   --will be done when Apptus Order and orderlineitem are available	
				NULL														as NetPrice,   --will be done when Apptus Order and orderlineitem are available

				u.[Name]													as iTeroSalesRep,
				c.[Priority]												as [Priority],
	
				--Scanner Model should be added later from Opportunity

				--c.[Audit_Completed_Steps__c]								as AuditCompletedSteps,
				--c.[Auditing_Stage_Status__c]								as AuditingStageStatus,
	
				c.[Audit_Staus__c]											as AuditStatus,
				--NULL														as AuditTimeElapsed,  -- should be added later
				/*o.[Scanner_SN__c]*/
				case 
					when left(C.[Serial_Number__c], 2)= '1Z' 
					then C.[Tracking_Number__c] 
					else isnull(o.[Scanner_SN__c],C.[Serial_Number__c]) 
				end															as SerialNumber,
				c.[Manufacturing_Date__c]									as DeliveredDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as DeliveredDateKey,
				c.CaseNumber												as TicketNumber,
				c.Final_Status__c											as FinalStatus,
				c.Scanner_Quantity__c										as ScannerQuantity,
				convert(int, convert(varchar(8), c.CreatedDate, 112))		as ContractOpenDateKey,
				c.CreatedDate												as ContractOpenDate,
				isnull(o.[Shipped_Date__c],c.[Processing_completed_date__c]) as ContractDate,
				YEAR (isnull(o.[Shipped_Date__c],c.[Processing_completed_date__c]))*10000+
				MONTH(isnull(o.[Shipped_Date__c],c.[Processing_completed_date__c]))*100+		
				DAY  (isnull(o.[Shipped_Date__c],c.[Processing_completed_date__c]))							as ContractDateKey,
				o.Opportunity_Number__c										as OpportunityNumber,

				isnull(o.Cancellation_Date__c,c.Cancelled_Date__c)			as CancellationDate	,
				YEAR (isnull(o.Cancellation_Date__c,c.Cancelled_Date__c)	)*10000+
				MONTH(isnull(o.Cancellation_Date__c,c.Cancelled_Date__c)	)*100+		
				DAY  (isnull(o.Cancellation_Date__c,c.Cancelled_Date__c)	)							as CancellationDateKey,
				/* added */
				o.Contract_Loaded__c										as  [Opp_Contract_Date],
				c.Processing_completed_date__c 								as	[Ticket_Contract_Date],
				o.Shipped_Date__c											as  [Opp_Ship_Date],
				c.Effective_Shipment_date__c								as  [Ticket_Ship_Date],
				o.Scanner_Quantity__c										as	[Opp_Qty],
				c.Scanner_Quantity__c										as  [Ticket_Qty],
				o.RecordTypeId												as  [Opp_RecordTypeId],
				
				o.StageName													as  [Opp_StageName],
				c.Cancellation_received__c									as  [Ticket_Cancellation_received],
				o.Cancellation_Date__c										as  [Opp_Cancellation_Date],
				c.Total_Purchase_Price__c									as  [Ticket_Purchase_Price],
				o.Sale_Type__c												as  [Opp_Purchase_Price],

				o.Product_Option__c											as  [Opp_Product_Option],
				convert(nvarchar(510),null)/*c.Scanner_Model__c*/											as  [Ticket_Scanner_Model],
				rt_c.[Name]													as  [Ticket_RecordType],
				rt_o.[Name]													as  [Opp_RecordType],
				prod.[Family]												as  [ProductFamily],
				prod.[Name]													as  [ProductName],
				prod.[ProductCode]											as  [ProductCode],
				prod.[OplQuantity]											as  [OplQuantity],
				prod.[OplProductCode]										as  [OplProductCode],
				o.Commission_Date__c										as  [Opp_Commission_Date],
				o.[Description]												as	[Opp_Description],
				prod.IsDeleted												as  [IsDeleted],
				o.Scanner_Sales_Channel__c									as  [Opp_EMEA_Sales_Channel],
				o.Distributor__c											as  [Opp_Distributor],
				o.iTero_Type__c												as  [Opp_iTero_Type],
				case 
				When o.[Promotion__c] is null and (o.[Scanner_SN__c] like 'BLX%' or o.[Scanner_SN__c] like 'RTC%') 
					then 'No Promo'
				else isnull(o.[Promotion__c] ,o.[Scanner_SN__c] )
				end															as  [Opp_Promotion],
				o.CloseDate													as	[OppCloseDate],
				o.Contact__c												as 	[ContactId],
				prod.OpportunityLineItemID									as  [OpportunityLineItemID],
				case 
					when orl.Parent_Opportunity__c is not null
					then 1
					else 0 
				end															as IsChildOpportunity
FROM SrcSFDC.[Case] c
	inner join DWIRIS.HubSalesContract h 
		on c.Id = h.KeySalesContract
		and h.SourceSystemCode = 'SFDC'
	left join SrcSFDC.Opportunity o 
		on c.Opportunity__c = o.Id
	left join SrcSFDC.[User] u 
		on c.OwnerId = u.Id
	left join DWIRIS.HubUser uh
		on u.Id = uh.KeyUser
	left join DWIRIS.HubAsset asseth
		on isnull(o.[Scanner_SN__c],C.[Serial_Number__c]) = asseth.KeyAsset
	left join DW.HubAccount ah
		on c.AccountId = ah.KeyAccount
	left join DWIRIS.HubTeam th
		on c.Team_Function__c = th.KeyTeam
	left join SrcSFDC.RecordType rt_c
		on rt_c.Id = c.RecordTypeId
	left join SrcSFDC.RecordType rt_o
		on rt_o.Id = o.RecordTypeId
	left join 
		(
		select 
			Opportunity_Number__c,
			oppline.Quantity as OplQuantity,
			oppline.ProductCode as OplProductCode,
			Prd.FAMILY , 
			Prd.[Name], 
			Prd.ProductCode,
			oppline.IsDeleted,
			oppline.id as OpportunityLineItemID 
		from [SrcSFDC].[Opportunity] opp
		left join [SrcSFDC].[OpportunityLineItem] oppline 
			on opp.ID = oppline.OpportunityId
		LEFT JOIN [SrcSFDC].[Product2] Prd 
			on prd.id = oppline.Product2Id
		where opp.RecordTypeId in ('012i00000019r6NAAQ','0120H000000yUddQAE','0120H000001J6QaQAK','0120H000001QT9eQAG','0120H000000u011QAA')
		--sand YEAR(opp.CreatedDate) > 2019
		) prod
	 on prod.Opportunity_Number__c = o.Opportunity_Number__c
	left join [SrcSFDC].[Opportunity_Relationship__c] orl
					on orl.Child_Opportunity__c = o.Id
	where isnull(o.RecordTypeId,'') NOT IN ('0120H000001QT9eQAG','012i00000019r6NAAQ','0120H000000yUddQAE','0120H000001J6QaQAK','0120H000000u011QAA')
	/*where  
	
			C.[Symptom_Code__c] in ('iTero Orthodontic', 'iTero Restorative')
		and isnull(C.Total_Purchase_Price__c,0) <> 0 
		and (
				Scanner_Model__c is not null 
				or Processing_completed_date__c is not null 
				or C.Scanner_Quantity__c is not null 
				or Contract_Signature_date__c is not null 
				or Final_Status__c is not null 
				or Effective_Shipment_date__c is not null /* need to add column to SrcSFDC.[Case]*/
				or Shipment__c is not null				/* need to add column to SrcSFDC.[Case]*/
				or C.Contract_Type__c is not null			/* need to add column to SrcSFDC.[Case]*/
				or DistributorDSO_Name__c is not null		/* need to add column to SrcSFDC.[Case]*/
				or C.Order_Status__c is not null
			)
			*/
UNION ALL
	select 
				h.SKSalesContract											as SKSalesContract,
				o.ADLSBatchID,
				o.ADLSTimestamp,
				o.LZBatchID,
				
				convert(char(40), '')										as DWHash,
				h.KeySalesContract											as KeySalesContract,
	
				isnull(asseth.SKAsset, -1)									as SKAsset,
				isnull(ah.SKAccount, -1)									as SKAccount,
				isnull(th.SKTeam, -1)										as SKTeam,
				isnull(uh.SKUser, -1)										as SKUser,

				c.Audit_completed_date__c									as AuditCompletedDate,
				YEAR (c.Audit_completed_date__c)*10000+
				MONTH(c.Audit_completed_date__c)*100+
				DAY  (c.Audit_completed_date__c)							as AuditCompletedDateKey,
							
				c.[Manufacturing_Date__c]									as CaseManufacturingDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as CaseManufacturingDateKey,

				convert(datetime2,NULL)/*c.[Contract_Signature_date__c]*/	as ContractSignedDate,
				convert(int,null)/*YEAR (c.[Contract_Signature_date__c])*10000+
				MONTH(c.[Contract_Signature_date__c])*100+		
				DAY  (c.[Contract_Signature_date__c])*/						as ContractSignedDateKey,
	
				c.[Date_First_Contact_Email__c]								as FirstContactEmailDate,
				YEAR (c.[Date_First_Contact_Email__c])*10000+
				MONTH(c.[Date_First_Contact_Email__c])*100+		
				DAY  (c.[Date_First_Contact_Email__c])						as FirstContactEmailDateKey,

				c.[Date_Fourth_Contact__c]									as FourthContactDate,
				YEAR (c.[Date_Fourth_Contact__c])*10000+
				MONTH(c.[Date_Fourth_Contact__c])*100+		
				DAY  (c.[Date_Fourth_Contact__c])							as FourthContactDateKey,
	
				c.[Date_MiM__c]												as MiMDate,
				YEAR (c.[Date_MiM__c])*10000+
				MONTH(c.[Date_MiM__c])*100+		
				DAY  (c.[Date_MiM__c])										as MiMDateKey,

				c.[Date_Notification_Sent_to_Trainer__c]					as NotificationSenttoTrainerDate,
				YEAR (c.[Date_Notification_Sent_to_Trainer__c])*10000+
				MONTH(c.[Date_Notification_Sent_to_Trainer__c])*100+		
				DAY  (c.[Date_Notification_Sent_to_Trainer__c])				as NotificationSenttoTrainerDateKey,	
	
				c.[Date_Third_Contact__c]									as ThirdContactDate,
				YEAR (c.[Date_Third_Contact__c])*10000+
				MONTH(c.[Date_Third_Contact__c])*100+		
				DAY  (c.[Date_Third_Contact__c])							as ThirdContactDateKey,

				c.[Invoice_Date__c]											as InvoiceDate,
				YEAR (c.[Invoice_Date__c])*10000+
				MONTH(c.[Invoice_Date__c])*100+		
				DAY  (c.[Invoice_Date__c])									as InvoiceDateKey,

				convert(datetime2,NULL)										as DimLeasingStatusDate,
				convert(int,NULL)											as DimLeasingStatusDateKey,
	
				c.[Final_Received_Date__c]									as FinalReceivedDate,
				YEAR (c.[Final_Received_Date__c])*10000+
				MONTH(c.[Final_Received_Date__c])*100+		
				DAY  (c.[Final_Received_Date__c])							as FinalReceivedDateKey,

				c.[iTero_Scanner_Rev_Req_Date__c]							as iTeroScannerRevRecDate,
				YEAR (c.[iTero_Scanner_Rev_Req_Date__c])*10000+
				MONTH(c.[iTero_Scanner_Rev_Req_Date__c])*100+		
				DAY  (c.[iTero_Scanner_Rev_Req_Date__c])					as iTeroScannerRevRecDateKey,

				c.[Order_Status__c]											as CaseOrderStatus,
				o.[Order_status__c]											as OpportunityOrderStatus,

				c.[ClosedDate]												as OnboardingDate,
				YEAR (c.[ClosedDate])*10000+
				MONTH(c.[ClosedDate])*100+		
				DAY  (c.[ClosedDate])										as OnboardingDateKey,

				convert(nvarchar(255),null)/*c.[Request_Format__c]*/		as PaymentMethod,

				c.[Processing_completed_date__c]							as ProcessingCompletedDate,
				YEAR (c.[Processing_completed_date__c])*10000+
				MONTH(c.[Processing_completed_date__c])*100+		
				DAY  (c.[Processing_completed_date__c])						as ProcessingCompletedDateKey,

				o.[Shipped_Date__c]											as ShippingDate,
				YEAR (o.[Shipped_Date__c])*10000+
				MONTH(o.[Shipped_Date__c])*100+		
				DAY  (o.[Shipped_Date__c])									as ShippingDateKey,

				c.[Manufacturing_Date__c]									as SpareDeliveryDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as SpareDeliveryDateKey,

				c.[VCT_Training_Date__c]									as VCTTrainingDate,
				YEAR (c.[VCT_Training_Date__c])*10000+
				MONTH(c.[VCT_Training_Date__c])*100+		
				DAY  (c.[VCT_Training_Date__c])								as VCTTrainingDateKey,

				convert(decimal(18,2),null)/*c.[Audit_Time_Elapsed__c]*/									as AuditTimeElapsed,
				c.[ProcessingTimeElapsed_V1__c]								as ProcessingTimeElapsed,
				c.[Shipment_Time_Elapsed_V1__c]								as ShipmentTimeElapsed,

				NULL														as ListPrice,  --will be done when Apptus Order and orderlineitem are available
				NULL														as Discount,   --will be done when Apptus Order and orderlineitem are available	
				NULL														as NetPrice,   --will be done when Apptus Order and orderlineitem are available

				u.[Name]													as iTeroSalesRep,
				c.[Priority]												as [Priority],
	
				--Scanner Model should be added later from Opportunity

				--c.[Audit_Completed_Steps__c]								as AuditCompletedSteps,
				--c.[Auditing_Stage_Status__c]								as AuditingStageStatus,
	
				c.[Audit_Staus__c]											as AuditStatus,
				--NULL														as AuditTimeElapsed,  -- should be added later
				/*o.[Scanner_SN__c]*/
				case 
					when left(C.[Serial_Number__c], 2)= '1Z' 
					then C.[Tracking_Number__c] 
					else isnull(o.[Scanner_SN__c],C.[Serial_Number__c]) 
				end															as SerialNumber,
				c.[Manufacturing_Date__c]									as DeliveredDate,
				YEAR (c.[Manufacturing_Date__c])*10000+
				MONTH(c.[Manufacturing_Date__c])*100+		
				DAY  (c.[Manufacturing_Date__c])							as DeliveredDateKey,
				c.CaseNumber												as TicketNumber,
				c.Final_Status__c											as FinalStatus,
				c.Scanner_Quantity__c										as ScannerQuantity,
				convert(int, convert(varchar(8), c.CreatedDate, 112))		as ContractOpenDateKey,
				c.CreatedDate												as ContractOpenDate,
				
				o.[Contract_Signed_Date__c]									as ContractDate,
				YEAR (o.[Contract_Signed_Date__c])*10000+
				MONTH(o.[Contract_Signed_Date__c])*100+		
				DAY  (o.[Contract_Signed_Date__c])							as ContractDateKey,
				o.Opportunity_Number__c										as OpportunityNumber,

				o.Cancellation_Date__c										as CancellationDate,	
				YEAR (o.Cancellation_Date__c	)*10000+
				MONTH(o.Cancellation_Date__c	)*100+		
				DAY  (o.Cancellation_Date__c	)							as CancellationDateKey,
				/* added */
				o.Contract_Loaded__c										as  [Opp_Contract_Date],
				c.Processing_completed_date__c 								as	[Ticket_Contract_Date],
				o.Shipped_Date__c											as  [Opp_Ship_Date],
				c.Effective_Shipment_date__c								as  [Ticket_Ship_Date],
				o.Scanner_Quantity__c										as	[Opp_Qty],
				c.Scanner_Quantity__c										as  [Ticket_Qty],
				o.RecordTypeId												as  [Opp_RecordTypeId],
				
				o.StageName													as  [Opp_StageName],
				c.Cancellation_received__c									as  [Ticket_Cancellation_received],
				o.Cancellation_Date__c										as  [Opp_Cancellation_Date],
				c.Total_Purchase_Price__c									as  [Ticket_Purchase_Price],
				o.Sale_Type__c												as  [Opp_Purchase_Price],

				o.Product_Option__c											as  [Opp_Product_Option],
				convert(nvarchar(510),null)/*c.Scanner_Model__c*/											as  [Ticket_Scanner_Model],
				rt_c.[Name]													as  [Ticket_RecordType],
				rt_o.[Name]													as  [Opp_RecordType],
				prod.[Family]												as  [ProductFamily],
				prod.[Name]													as  [ProductName],
				convert(nvarchar(40),prod.[ProductCode]	)										as  [ProductCode],
				prod.[OplQuantity]											as  [OplQuantity],
				prod.[OplProductCode]										as  [OplProductCode],
				o.Commission_Date__c										as  [Opp_Commission_Date],
				o.[Description]												as	[Opp_Description],
				prod.IsDeleted												as  [IsDeleted],
				
				o.Scanner_Sales_Channel__c									as  [Opp_EMEA_Sales_Channel],
				o.Distributor__c											as  [Opp_Distributor],
				o.iTero_Type__c												as  [Opp_iTero_Type],
				case 
				When o.[Promotion__c] is null and (o.[Scanner_SN__c] like 'BLX%' or o.[Scanner_SN__c] like 'RTC%') 
					then 'No Promo'
				else isnull(o.[Promotion__c] ,o.[Scanner_SN__c] )
				end															as  [Opp_Promotion],
				o.CloseDate													as	[OppCloseDate],
				o.Contact__c												as 	[ContactId],
				prod.OpportunityLineItemID									as  [OpportunityLineItemID],
				case 
					when orl.Parent_Opportunity__c is not null
					then 1
					else 0 
				end															as IsChildOpportunity
	
	FROM SrcSFDC.[Opportunity] o
	inner join DWIRIS.HubSalesContract h 
		on o.Id = h.KeySalesContract
	left join (
				select 
					t.*
				from (
					select 
						ROW_NUMBER() OVER ( PARTITION BY Tick.Opportunity__c ORDER BY Tick.[CreatedDate]) as row_num,
						Tick.*
					from [SrcSFDC].[Case] Tick 
					where isnull(Tick.Opportunity__c,'')<>'' AND Tick.RecordTypeId in ('0120H000001J6QXQA0') 
					 ) t 
				where t.row_num = 1
			  ) c
		on c.Opportunity__c = o.Id
	left join SrcSFDC.[User] u 
		on c.OwnerId = u.Id
	left join DWIRIS.HubUser uh
		on u.Id = uh.KeyUser
	left join DWIRIS.HubAsset asseth
		on o.Scanner_SN__c = asseth.KeyAsset /* which serial number we should use? o.Scanner_SN__c, c.Serial_Number__c ? */
	left join DW.HubAccount ah
		on o.AccountId = ah.KeyAccount
	left join DWIRIS.HubTeam th
		on c.Team_Function__c = th.KeyTeam
	left join SrcSFDC.RecordType rt_c
		on rt_c.Id = c.RecordTypeId
	left join SrcSFDC.RecordType rt_o
		on rt_o.Id = o.RecordTypeId
	left join 
		(
		select 
			Opportunity_Number__c, 
			oppline.Quantity as OplQuantity,
			oppline.ProductCode as OplProductCode,
			Prd.FAMILY , 
			Prd.[Name], 
			Prd.ProductCode,
			oppline.IsDeleted,
			oppline.id as OpportunityLineItemID	
		from [SrcSFDC].[Opportunity] opp
		left join [SrcSFDC].[OpportunityLineItem] oppline 
			on opp.ID = oppline.OpportunityId
		LEFT JOIN [SrcSFDC].[Product2] Prd 
			on prd.id = oppline.Product2Id
		where opp.RecordTypeId in ('012i00000019r6NAAQ','0120H000000yUddQAE','0120H000001J6QaQAK','0120H000001QT9eQAG','0120H000000u011QAA')
		--and YEAR(opp.CreatedDate) > 2019
		) prod
	 on prod.Opportunity_Number__c = o.Opportunity_Number__c
	 left join [SrcSFDC].[Opportunity_Relationship__c] orl
					on orl.Child_Opportunity__c = o.Id
	--where ISNULL(c.RecordTypeId, '') in ('0120H000001J6QXQA0','0120H000001UWYrQAO', '')
	/*where  
		o.stagename <> 'Inactive' and o.stagename not like '%Lab%' and
					(
						o.sale_type__c is not null
					or o.stagename is not null
					or o.Tracking__c is not null
					or o.Contract_Signed_Date__c is not null
					)
	*/
		
	--update HASH
	update #TempDimSalesContract set DWHash=
		convert(char(40),
			hashbytes('SHA1',
				         ISNULL(convert(nvarchar,KeySalesContract),'')
					+'|'+ISNULL(convert(nvarchar,SKAsset),'')
					+'|'+ISNULL(convert(nvarchar,SKAccount),'')
					+'|'+ISNULL(convert(nvarchar,SKTeam),'')
					+'|'+ISNULL(convert(nvarchar,SKUser),'')
					+'|'+ISNULL(convert(nvarchar,AuditCompletedDate),'')
					+'|'+ISNULL(convert(nvarchar,CaseManufacturingDate),'')
					+'|'+ISNULL(convert(nvarchar,ContractSignedDate),'')
					+'|'+ISNULL(convert(nvarchar,FirstContactEmailDate),'')
					+'|'+ISNULL(convert(nvarchar,FourthContactDate),'')
					+'|'+ISNULL(convert(nvarchar,MiMDate),'')
					+'|'+ISNULL(convert(nvarchar,NotificationSenttoTrainerDate),'')
					+'|'+ISNULL(convert(nvarchar,ThirdContactDate),'')
					+'|'+ISNULL(convert(nvarchar,InvoiceDate),'')
					+'|'+ISNULL(convert(nvarchar,DimLeasingStatusDate),'')
					+'|'+ISNULL(convert(nvarchar,FinalReceivedDate),'')
					+'|'+ISNULL(convert(nvarchar,iTeroScannerRevRecDate),'')
					+'|'+ISNULL(convert(nvarchar,CaseOrderStatus),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityOrderStatus),'')
					+'|'+ISNULL(convert(nvarchar,OnboardingDate),'')
					+'|'+ISNULL(convert(nvarchar,PaymentMethod),'')
					+'|'+ISNULL(convert(nvarchar,ProcessingCompletedDate),'')
					+'|'+ISNULL(convert(nvarchar,SpareDeliveryDate),'')
					+'|'+ISNULL(convert(nvarchar,VCTTrainingDate),'')
					+'|'+ISNULL(convert(nvarchar,DeliveredDate),'')
					+'|'+ISNULL(convert(nvarchar,AuditTimeElapsed),'')
					+'|'+ISNULL(convert(nvarchar,ProcessingTimeElapsed),'')
					+'|'+ISNULL(convert(nvarchar,ShipmentTimeElapsed),'')
					+'|'+ISNULL(convert(nvarchar,ListPrice),'')
					+'|'+ISNULL(convert(nvarchar,Discount),'')
					+'|'+ISNULL(convert(nvarchar,NetPrice),'')
					+'|'+ISNULL(convert(nvarchar,iTeroSalesRep),'')
					+'|'+ISNULL(convert(nvarchar,[Priority]),'')
					--+'|'+ISNULL(convert(nvarchar,AuditCompletedSteps),'')
					--+'|'+ISNULL(convert(nvarchar,AuditingStageStatus),'')
					+'|'+ISNULL(convert(nvarchar,AuditStatus),'')
					+'|'+ISNULL(convert(nvarchar,SerialNumber),'')
					+'|'+ISNULL(convert(nvarchar,DeliveredDate),'')
					+'|'+ISNULL(convert(nvarchar,TicketNumber),'')
					+'|'+ISNULL(convert(nvarchar,FinalStatus),'')
					+'|'+ISNULL(convert(nvarchar,ScannerQuantity),'')
					+'|'+ISNULL(convert(nvarchar,ContractOpenDate),'')

					+'|'+ISNULL(convert(nvarchar,ContractDate),'')
					+'|'+ISNULL(convert(nvarchar,OpportunityNumber),'')
					+'|'+ISNULL(convert(nvarchar,CancellationDate),'')
					/* added */
					+'|'+ISNULL(convert(nvarchar,Opp_Contract_Date),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Contract_Date),'')
					+'|'+ISNULL(convert(nvarchar,Opp_Ship_Date),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Ship_Date),'')
					+'|'+ISNULL(convert(nvarchar,Opp_Qty),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Qty),'')
					+'|'+ISNULL(convert(nvarchar,Opp_RecordTypeId),'')

					+'|'+ISNULL(convert(nvarchar,Opp_StageName),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Cancellation_received),'')
					+'|'+ISNULL(convert(nvarchar,Opp_Cancellation_Date),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Purchase_Price),'')
					+'|'+ISNULL(convert(nvarchar,Opp_Purchase_Price),'')
					+'|'+ISNULL(convert(nvarchar,Opp_Product_Option),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_Scanner_Model),'')
					+'|'+ISNULL(convert(nvarchar,Ticket_RecordType),'')
					+'|'+ISNULL(convert(nvarchar,Opp_RecordType),'')

					+'|'+ISNULL(convert(nvarchar,ProductFamily),'')
					+'|'+ISNULL(convert(nvarchar,ProductName),'')
					+'|'+ISNULL(convert(nvarchar,ProductCode),'')
					+'|'+ISNULL(convert(nvarchar,OplQuantity),'')
					+'|'+ISNULL(convert(nvarchar,OplProductCode),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_Commission_Date]),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_Description]),'')
					+'|'+ISNULL(convert(nvarchar,[IsDeleted]),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_EMEA_Sales_Channel]),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_Distributor]),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_iTero_Type]),'')
					+'|'+ISNULL(convert(nvarchar,[Opp_Promotion]),'')
					+'|'+ISNULL(convert(nvarchar,[OppCloseDate]),'')
					+'|'+ISNULL(convert(nvarchar,[ContactId]),'')
					+'|'+ISNULL(convert(nvarchar,[OpportunityLineItemID]),'')
					+'|'+ISNULL(convert(nvarchar,[IsChildOpportunity]),'')
					
				)
			,2)

	--   Create Unknow Element in case there is none
	if not exists (select * from [DWIRIS].[DimSalesContract] where SKSalesContract = -1)
	begin
		declare @Hash char(40) = ''

		insert into DWIRIS.DimSalesContract (
				[SKSalesContract]
				,[ADLSBatchID]
				,[ADLSTimestamp]
				,[LZBatchID]
				,[DWBatchID]
				,[DWHash]
				,[KeySalesContract]
				,[SKAsset]
				,[SKAccount]
				,[SKTeam]
				,[SKUser]
				,[AuditCompletedDate]
				,[AuditCompletedDateKey]
				,[CaseManufacturingDate]
				,[CaseManufacturingDateKey]
				,[ContractSignedDate]
				,[ContractSignedDateKey]
				,[FirstContactEmailDateKey]
				,[FirstContactEmailDate]
				,[FourthContactDateKey]
				,[FourthContactDate]
				,[MiMDateKey]
				,[MiMDate]
				,[NotificationSenttoTrainerDateKey]
				,[NotificationSenttoTrainerDate]
				,[ThirdContactDateKey]
				,[ThirdContactDate]
				,[InvoiceDateKey]
				,[InvoiceDate]
				,[DimLeasingStatusDateKey]
				,[DimLeasingStatusDate]
				,[FinalReceivedDateKey]
				,[FinalReceivedDate]
				,[iTeroScannerRevRecDateKey]
				,[iTeroScannerRevRecDate]
				,[CaseOrderStatus]
				,[OpportunityOrderStatus]
				,[OnboardingDateKey]
				,[OnboardingDate]
				,[PaymentMethod]
				,[ProcessingCompletedDateKey]
				,[ProcessingCompletedDate]
				,[ShippingDateKey]
				,[ShippingDate]
				,[SpareDeliveryDateKey]
				,[SpareDeliveryDate]
				,[VCTTrainingDateKey]
				,[VCTTrainingDate]
				,[AuditTimeElapsed]
				,[ProcessingTimeElapsed]
				,[ShipmentTimeElapsed]
				,[iTeroSalesRep]
				,[Priority]
				--,[AuditCompletedSteps]
				--,[AuditingStageStatus]
				,[AuditStatus]
				,[SerialNumber]
				,[DeliveredDateKey]
				,[DeliveredDate]
				,[TicketNumber]
				,[FinalStatus]
				,[ScannerQuantity]
				,[ContractOpenDateKey]
				,[ContractOpenDate]
				,[ContractDate]
				,[ContractDateKey]
				,[OpportunityNumber]
				,[CancellationDate]
				,[CancellationDateKey]
				,[Opp_Contract_Date]
				,[Ticket_Contract_Date]
				,[Opp_Ship_Date]
				,[Ticket_Ship_Date]
				,[Opp_Qty]
				,[Ticket_Qty]
				,[Opp_RecordTypeId]
				,[Opp_StageName]
				,[Ticket_Cancellation_received]
				,[Opp_Cancellation_Date]
				,[Ticket_Purchase_Price]
				,[Opp_Purchase_Price]
				,[Opp_Product_Option]
				,[Ticket_Scanner_Model]
				,[Ticket_RecordType]
				,[Opp_RecordType]
				,[ProductFamily]
				,[ProductName]
				,[ProductCode]
				,[OplQuantity]
				,[OplProductCode]
				,[Opp_Commission_Date]
				,[Opp_Description]
				,[IsDeleted]
				,[Opp_EMEA_Sales_Channel]
				,[Opp_Distributor]
				,[Opp_iTero_Type]
				,[Opp_Promotion]
				,[OppCloseDate]
				,[ContactId]
				,[OpportunityLineItemID]
				,[IsChildOpportunity]
		)
		values (
				-1					-- SKAsset
			,	-1					-- ADLSBatchID
			,	'19000101'			-- ADLSTimestamp
			,	-1					-- LZBatchID
			,	@BatchID			-- DWBatchID
			,	@Hash				-- DWHash
				
			,   'N/A'				--[KeySalesContract]
			,	-1					--[SKAsset]
			,	-1					--[SKAccount]
			,	-1					--[SKTeam]
			,	-1					--[SKUser]
			,	'19000101'			--[AuditCompletedDate]
			,	19000101			--[AuditCompletedDateKey]
			,	'19000101'			--[CaseManufacturingDate]
			,	19000101			--[CaseManufacturingDateKey]
			,	'19000101'			--[ContractSignedDate]
			,	19000101			--[ContractSignedDateKey]
			,   19000101			--[FirstContactEmailDateKey]
			,	'19000101'			--[FirstContactEmailDate]
			,   19000101			--[FourthContactDateKey]
			,	'19000101'			--[FourthContactDate]
			,   19000101			--[MiMDateKey]
			,	'19000101'			--[MiMDate]
			,   19000101			--[NotificationSenttoTrainerDateKey]
			,	'19000101'			--[NotificationSenttoTrainerDate]
			,   19000101		    --[ThirdContactDateKey]
			,	'19000101'			--[ThirdContactDate]
			,   19000101			--[InvoiceDateKey]
			,	'19000101'			--[InvoiceDate]
			,   19000101			--[DimLeasingStatusDateKey]
			,	'19000101'			--[DimLeasingStatusDate]
			,   19000101			--[FinalReceivedDateKey]
			,	'19000101'			--[FinalReceivedDate]
			,   19000101			--[iTeroScannerRevRecDateKey]
			,   '19000101'			--[iTeroScannerRevRecDate]
			,   'N/A'			    --[CaseOrderStatus]
			,   'N/A'			    --[OpportunityOrderStatus]
			,   19000101			--[OnboardingDateKey]
			,   '19000101'			--[OnboardingDate]
			,   'N/A'				--[PaymentMethod]
			,   19000101			--[ProcessingCompletedDateKey]
			,   '19000101'			--[ProcessingCompletedDate]
			,   19000101			--[ShippingDateKey]
			,   '19000101'			--[ShippingDate]
			,   19000101			--[SpareDeliveryDateKey]
			,   '19000101'			--[SpareDeliveryDate]
			,   19000101			--[VCTTrainingDateKey]
			,   '19000101'			--[VCTTrainingDate]
			,   NULL				--[AuditTimeElapsed]
			,   NULL			    --[ProcessingTimeElapsed]
			,   NULL			    --[ShipmentTimeElapsed]
			,   'N/A'				--[iTeroSalesRep]
			,   NULL			    --[Priority]
			--,   NULL			    --[AuditCompletedSteps]
			--,   'N/A'				--[AuditingStageStatus]
			,   'N/A'			    --[AuditStatus]
			,   'N/A'				--[SerialNumber]
			,   19000101			--[DeliveredDateKey]
			,   '19000101'			--[DeliveredDate]
			,	'N/A'				--[TicketNumber]
			,	'N/A'				--[FinalStatus]
			,	-1					--[ScannerQuantity]
			,   19000101			--[ContractOpenDateKey]
			,   '19000101'			--[ContractOpenDate]
			,   '19000101'			--[ContractDate]
			,   19000101			--[ContractDateKey]
			,	'N/A'				--[OpportunityNumber]
			,   '19000101'			--[CancellationDate]
			,   19000101			--[CancellationDateKey]
			,	'19000101'			--[Opp_Contract_Date]
			,	'19000101'			--[Ticket_Contract_Date]
			,	'19000101'			--[Opp_Ship_Date]
			,	'19000101'			--[Ticket_Ship_Date]
			,	0					--[Opp_Qty]
			,	0					--[Ticket_Qty]
			,	'N/A'				--[Opp_RecordTypeId]

			,	'N/A'				--[Opp_StageName]
			,	'N/A'				--[Ticket_Cancellation_received]
			,	'19000101'			--[Opp_Cancellation_Date]
			,	0					--[Ticket_Purchase_Price]
			,	'N/A'				--[Opp_Purchase_Price]
			,	'N/A'				--[Opp_Product_Option]
			,	'N/A'				--[Ticket_Scanner_Model]
			,	'N/A'				--[Ticket_RecordType]
			,	'N/A'				--[Opp_RecordType]
			,	'N/A'				--[ProductFamily]
			,	'N/A'				--[ProductName]
			,	'N/A'				--[ProductCode]
			,	0					--[OplQuantity]
			,	'N/A'				--[OplProductCode]
			,	'19000101'			--[Opp_Commission_Date]
			,	'N/A'				--[Opp_Description]
			,	0					--[IsDeleted]
			,'N/A'					--[Opp_EMEA_Sales_Channel]
			,'N/A'					--[Opp_Distributor]
			,'N/A'					--[Opp_iTero_Type]
			,'N/A'					--[Opp_Promotion]
			,'19000101'				--[OppCloseDate]
			,'N/A'					--[ContactId]
			,'N/A'					--OpportunityLineItemID
			,-1						--[IsChildOpportunity]
	)
	end


	--  End  createing unknow element


	-- UPDATE existing Dim rows where HASH has changed (due to attribute value change)
	update [DWIRIS].[DimSalesContract]
		set
		     ADLSBatchID = src.ADLSBatchID
			,ADLSTimestamp = src.ADLSTimestamp
			,LZBatchID = src.LZBatchID
			,DWBatchID = @BatchID
			,DWHash = src.DWHash
			
		  ,[SKAsset]									=	src.[SKAsset]
		  ,[SKAccount]									=	src.[SKAccount]
		  ,[SKTeam]										=	src.[SKTeam]
		  ,[SKUser]										=	src.[SKUser]
		  ,[AuditCompletedDate]							=	src.[AuditCompletedDate]
 		  ,[AuditCompletedDateKey]						=	src.[AuditCompletedDateKey]
		  ,[CaseManufacturingDate]						=	src.[CaseManufacturingDate]
		  ,[CaseManufacturingDateKey]					=	src.[CaseManufacturingDateKey]
		  ,[ContractSignedDate]							=	src.[ContractSignedDate]
		  ,[ContractSignedDateKey]						=	src.[ContractSignedDateKey]
		  ,[FirstContactEmailDateKey]					=	src.[FirstContactEmailDateKey]
		  ,[FirstContactEmailDate]						=	src.[FirstContactEmailDate]
		  ,[FourthContactDateKey]						=	src.[FourthContactDateKey]
		  ,[FourthContactDate]							=	src.[FourthContactDate]
		  ,[MiMDateKey]									=	src.[MiMDateKey]
		  ,[MiMDate]									=	src.[MiMDate]
		  ,[NotificationSenttoTrainerDateKey]			=	src.[NotificationSenttoTrainerDateKey]
		  ,[NotificationSenttoTrainerDate]				=	src.[NotificationSenttoTrainerDate]
		  ,[ThirdContactDateKey]						=	src.[ThirdContactDateKey]
		  ,[ThirdContactDate]							=	src.[ThirdContactDate]
		  ,[InvoiceDateKey]								=	src.[InvoiceDateKey]
		  ,[InvoiceDate]								=	src.[InvoiceDate]
		  ,[DimLeasingStatusDateKey]					=	src.[DimLeasingStatusDateKey]
		  ,[DimLeasingStatusDate]						=	src.[DimLeasingStatusDate]
		  ,[FinalReceivedDateKey]						=	src.[FinalReceivedDateKey]
		  ,[FinalReceivedDate]							=	src.[FinalReceivedDate]
		  ,[iTeroScannerRevRecDateKey]					=	src.[iTeroScannerRevRecDateKey]
		  ,[iTeroScannerRevRecDate]						=	src.[iTeroScannerRevRecDate]
		  ,[CaseOrderStatus]							=	src.[CaseOrderStatus]
		  ,[OpportunityOrderStatus]						=	src.[OpportunityOrderStatus]
		  ,[OnboardingDateKey]							=	src.[OnboardingDateKey]
		  ,[OnboardingDate]								=	src.[OnboardingDate]
		  ,[PaymentMethod]								=	src.[PaymentMethod]
		  ,[ProcessingCompletedDateKey]					=	src.[ProcessingCompletedDateKey]
		  ,[ProcessingCompletedDate]					=	src.[ProcessingCompletedDate]
		  ,[ShippingDateKey]							=	src.[ShippingDateKey]
		  ,[ShippingDate]								=	src.[ShippingDate]
		  ,[SpareDeliveryDateKey]						=	src.[SpareDeliveryDateKey]
		  ,[SpareDeliveryDate]							=	src.[SpareDeliveryDate]
		  ,[VCTTrainingDateKey]							=	src.[VCTTrainingDateKey]
		  ,[VCTTrainingDate]							=	src.[VCTTrainingDate]
		  ,[AuditTimeElapsed]							=	src.[AuditTimeElapsed]
		  ,[ProcessingTimeElapsed]						=	src.[ProcessingTimeElapsed]
		  ,[ShipmentTimeElapsed]						=	src.[ShipmentTimeElapsed]
		  ,[iTeroSalesRep]								=	src.[iTeroSalesRep]
		  ,[Priority]									=	src.[Priority]
		  --,[AuditCompletedSteps]						=	src.[AuditCompletedSteps]
		  --,[AuditingStageStatus]						=	src.[AuditingStageStatus]
		  ,[AuditStatus]								=	src.[AuditStatus]
		  ,[SerialNumber]								=	src.[SerialNumber]
		  ,[DeliveredDate]								=	src.[DeliveredDate]
		  ,[DeliveredDateKey]							=	src.[DeliveredDateKey]
		  ,[TicketNumber]								=	src.[TicketNumber]
		  ,[FinalStatus]								=	src.[FinalStatus]
		  ,[ScannerQuantity]							=	src.[ScannerQuantity]
		  ,[ContractOpenDateKey]						=	src.[ContractOpenDateKey]
		  ,[ContractOpenDate]							=	src.[ContractOpenDate]
		  ,[ContractDate]								=	src.[ContractDate]
		  ,[ContractDateKey]							=	src.[ContractDateKey]
		  ,[OpportunityNumber]							=	src.[OpportunityNumber]
		  ,[CancellationDate]							=	src.[CancellationDate]
		  ,[CancellationDateKey]						=	src.[CancellationDateKey]
		  ,[Opp_Contract_Date]							=	src.[Opp_Contract_Date]
		  ,[Ticket_Contract_Date]						=	src.[Ticket_Contract_Date]
		  ,[Opp_Ship_Date]								=	src.[Opp_Ship_Date]
		  ,[Ticket_Ship_Date]							=	src.[Ticket_Ship_Date]
		  ,[Opp_Qty]									=	src.[Opp_Qty]
		  ,[Ticket_Qty]									=	src.[Ticket_Qty]
		  ,[Opp_RecordTypeId]							=	src.[Opp_RecordTypeId]

		  ,[Opp_StageName]								=	src.[Opp_StageName]
		  ,[Ticket_Cancellation_received]				=	src.[Ticket_Cancellation_received]
		  ,[Opp_Cancellation_Date]						=	src.[Opp_Cancellation_Date]
		  ,[Ticket_Purchase_Price]						=	src.[Ticket_Purchase_Price]
		  ,[Opp_Purchase_Price]							=	src.[Opp_Purchase_Price]

		  ,[Opp_Product_Option]							=	src.[Opp_Product_Option]
		  ,[Ticket_Scanner_Model]						=	src.[Ticket_Scanner_Model]
		  ,[Ticket_RecordType]							=	src.[Ticket_RecordType]
		  ,[Opp_RecordType]								=	src.[Opp_RecordType]
		  ,[ProductFamily]								=	src.[ProductFamily]
		  ,[ProductName]								=	src.[ProductName]
		  ,[ProductCode]								=	src.[ProductCode]
		  ,[OplQuantity]								=	src.[OplQuantity]
		  ,[OplProductCode]								=	src.[OplProductCode]
		  ,[Opp_Commission_Date]						=	src.[Opp_Commission_Date]
		  ,[Opp_Description]							=	src.[Opp_Description]
		  ,[IsDeleted]									=	src.[IsDeleted]
		  ,[Opp_EMEA_Sales_Channel]						=	src.[Opp_EMEA_Sales_Channel]
		  ,[Opp_Distributor]							=	src.[Opp_Distributor]
		  ,[Opp_iTero_Type]								=	src.[Opp_iTero_Type]
		  ,[Opp_Promotion]								=	src.[Opp_Promotion]
		  ,[OppCloseDate]								=	src.[OppCloseDate]
		  ,[ContactId]								=	src.[ContactId]
		  ,[OpportunityLineItemID]					=   src.[OpportunityLineItemID]
		  ,[IsChildOpportunity]					=   src.[IsChildOpportunity]
	
	from #TempDimSalesContract src
	where [DWIRIS].[DimSalesContract].SKSalesContract	=	src.SKSalesContract
		and [DWIRIS].[DimSalesContract].DWHash != src.DWHash
		and ((isnull([DWIRIS].[DimSalesContract].[OpportunityNumber],'') ='')
		or(
			 isnull([DWIRIS].[DimSalesContract].[OpportunityNumber],'') = isnull(src.[OpportunityNumber],'') 
			 and isnull([DWIRIS].[DimSalesContract].[OpportunityLineItemID],'')=isnull(src.[OpportunityLineItemID],'')
		))
	option (label = 'DWIRIS.LoadDimSalesContract_Update');
	
	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimSalesContract_Update', @rc = @RowsUpdated out


	--INSERT new rows
	insert into [DWIRIS].[DimSalesContract] (
				   [SKSalesContract]
				  ,[ADLSBatchID]
				  ,[ADLSTimestamp]
				  ,[LZBatchID]
				  ,[DWBatchID]
				  ,[DWHash]
				  ,[KeySalesContract]
				  ,[SKAsset]
				  ,[SKAccount]
				  ,[SKTeam]
				  ,[SKUser]
				  ,[AuditCompletedDate]
				  ,[AuditCompletedDateKey]
				  ,[CaseManufacturingDate]
				  ,[CaseManufacturingDateKey]
				  ,[ContractSignedDate]
				  ,[ContractSignedDateKey]
				  ,[FirstContactEmailDateKey]
				  ,[FirstContactEmailDate]
				  ,[FourthContactDateKey]
				  ,[FourthContactDate]
				  ,[MiMDateKey]
				  ,[MiMDate]
				  ,[NotificationSenttoTrainerDateKey]
				  ,[NotificationSenttoTrainerDate]
				  ,[ThirdContactDateKey]
				  ,[ThirdContactDate]
				  ,[InvoiceDateKey]
				  ,[InvoiceDate]
				  ,[DimLeasingStatusDateKey]
				  ,[DimLeasingStatusDate]
				  ,[FinalReceivedDateKey]
				  ,[FinalReceivedDate]
				  ,[iTeroScannerRevRecDateKey]
				  ,[iTeroScannerRevRecDate]
				  ,[CaseOrderStatus]
				  ,[OpportunityOrderStatus]
				  ,[OnboardingDateKey]
				  ,[OnboardingDate]
				  ,[PaymentMethod]
				  ,[ProcessingCompletedDateKey]
				  ,[ProcessingCompletedDate]
				  ,[ShippingDateKey]
				  ,[ShippingDate]
				  ,[SpareDeliveryDateKey]
				  ,[SpareDeliveryDate]
				  ,[VCTTrainingDateKey]
				  ,[VCTTrainingDate]
				  ,[AuditTimeElapsed]
				  ,[ProcessingTimeElapsed]
				  ,[ShipmentTimeElapsed]
				  ,[iTeroSalesRep]
				  ,[Priority]
				  --,[AuditCompletedSteps]
				  --,[AuditingStageStatus]
				  ,[AuditStatus]
				  ,[SerialNumber]
				  ,[DeliveredDate]
				  ,[DeliveredDateKey]
				  ,[TicketNumber]
				  ,[FinalStatus]
				  ,[ScannerQuantity]
				  ,[ContractOpenDateKey]
				  ,[ContractOpenDate]
				  ,[ContractDate]
				,[ContractDateKey]
				,[OpportunityNumber]
				,[CancellationDate]
				,[CancellationDateKey]
				,[Opp_Contract_Date]
				,[Ticket_Contract_Date]
				,[Opp_Ship_Date]
				,[Ticket_Ship_Date]
				,[Opp_Qty]
				,[Ticket_Qty]
				,[Opp_RecordTypeId]

				,[Opp_StageName]
				,[Ticket_Cancellation_received]	
				,[Opp_Cancellation_Date]
				,[Ticket_Purchase_Price]
				,[Opp_Purchase_Price]
				,[Opp_Product_Option]
				,[Ticket_Scanner_Model]
				,[Ticket_RecordType]
				,[Opp_RecordType]
				,[ProductFamily]
				,[ProductName]
				,[ProductCode]
				,[OplQuantity]
				,[OplProductCode]
				,[Opp_Commission_Date]
				,[Opp_Description]
				,[IsDeleted]
				,[Opp_EMEA_Sales_Channel]
				,[Opp_Distributor]
				,[Opp_iTero_Type]
				,[Opp_Promotion]
				,[OppCloseDate]
				,[ContactId]
				,[OpportunityLineItemID]
				,[IsChildOpportunity]
		   )
	select 
				   [SKSalesContract]
				  ,[ADLSBatchID]
				  ,[ADLSTimestamp]
				  ,[LZBatchID]
				  ,@BatchID
				  ,[DWHash]
				  ,[KeySalesContract]
				  ,[SKAsset]
				  ,[SKAccount]
				  ,[SKTeam]
				  ,[SKUser]
				  ,[AuditCompletedDate]
				  ,[AuditCompletedDateKey]
				  ,[CaseManufacturingDate]
				  ,[CaseManufacturingDateKey]
				  ,[ContractSignedDate]
				  ,[ContractSignedDateKey]
				  ,[FirstContactEmailDateKey]
				  ,[FirstContactEmailDate]
				  ,[FourthContactDateKey]
				  ,[FourthContactDate]
				  ,[MiMDateKey]
				  ,[MiMDate]
				  ,[NotificationSenttoTrainerDateKey]
				  ,[NotificationSenttoTrainerDate]
				  ,[ThirdContactDateKey]
				  ,[ThirdContactDate]
				  ,[InvoiceDateKey]
				  ,[InvoiceDate]
				  ,[DimLeasingStatusDateKey]
				  ,[DimLeasingStatusDate]
				  ,[FinalReceivedDateKey]
				  ,[FinalReceivedDate]
				  ,[iTeroScannerRevRecDateKey]
				  ,[iTeroScannerRevRecDate]
				  ,[CaseOrderStatus]
				  ,[OpportunityOrderStatus]
				  ,[OnboardingDateKey]
				  ,[OnboardingDate]
				  ,[PaymentMethod]
				  ,[ProcessingCompletedDateKey]
				  ,[ProcessingCompletedDate]
				  ,[ShippingDateKey]
				  ,[ShippingDate]
				  ,[SpareDeliveryDateKey]
				  ,[SpareDeliveryDate]
				  ,[VCTTrainingDateKey]
				  ,[VCTTrainingDate]
				  ,[AuditTimeElapsed]
				  ,[ProcessingTimeElapsed]
				  ,[ShipmentTimeElapsed]
				  ,[iTeroSalesRep]
				  ,[Priority]
				  --,[AuditCompletedSteps]
				  --,[AuditingStageStatus]
				  ,[AuditStatus]
				  ,[SerialNumber]
				  ,[DeliveredDate]
				  ,[DeliveredDateKey]
				  ,[TicketNumber]
				  ,[FinalStatus]
				  ,[ScannerQuantity]
				  ,[ContractOpenDateKey]
				  ,[ContractOpenDate]
				  ,[ContractDate]
				  ,[ContractDateKey]
				,[OpportunityNumber]
				,[CancellationDate]
				,[CancellationDateKey]
				,[Opp_Contract_Date]
				,[Ticket_Contract_Date]
				,[Opp_Ship_Date]
				,[Ticket_Ship_Date]
				,[Opp_Qty]
				,[Ticket_Qty]
				,[Opp_RecordTypeId]
				,[Opp_StageName]
				,[Ticket_Cancellation_received]	
				,[Opp_Cancellation_Date]
				,[Ticket_Purchase_Price]
				,[Opp_Purchase_Price]
				,[Opp_Product_Option]
				,[Ticket_Scanner_Model]
				,[Ticket_RecordType]
				,[Opp_RecordType]
				,[ProductFamily]
				,[ProductName]
				,[ProductCode]
				,[OplQuantity]
				,[OplProductCode]
				,[Opp_Commission_Date]
				,[Opp_Description]
				,[IsDeleted]
				,[Opp_EMEA_Sales_Channel]
				,[Opp_Distributor]
				,[Opp_iTero_Type]
				,[Opp_Promotion]
				,[OppCloseDate]
				,[ContactId]
				,[OpportunityLineItemID]
				,[IsChildOpportunity]
	from #TempDimSalesContract src
	where not exists(select dst.SKSalesContract from DWIRIS.DimSalesContract dst where dst.SKSalesContract = src.SKSalesContract
	and(isnull(dst.SKSalesContract,'') = '' or
			(isnull(dst.[OpportunityNumber],'')= isnull(src.[OpportunityNumber],'') and isnull(dst.[OpportunityLineItemID],'')=isnull(src.[OpportunityLineItemID],'') 
			)
		)
	)
	option (label = 'DWIRIS.LoadDimSalesContract_Insert');

	exec CTRL.GetLastRowCount @Label = 'DWIRIS.LoadDimSalesContract_Insert', @rc = @RowsInserted out

	select @RowsInserted as RowsInserted, @RowsUpdated as RowsUpdated
	
end --procedure