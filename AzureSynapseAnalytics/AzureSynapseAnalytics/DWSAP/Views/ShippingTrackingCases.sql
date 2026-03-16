CREATE VIEW [DWSAP].[ShippingTrackingCases]
AS Select  
	       b.VGBEL as Ordernumber,
		   b.VGPOS as Orderitem,
           a.SHP_TRACKN as TrackingNumber,
		   a.SHP_PKGID as ShippingPkgID,
           b.VBELN as DeliveryNumber,
		   CAST(b.VBELN as int) as ShipExecReference,
           c.WADAT as PlannedGoodsMovementdate ,
		   c.WADAT_IST as ActualGoodsMovementdate,
           b.PSTYV as Deliveryitemcategory,
		   b.WERKS as Plant,
		   b.POSNR as DeliveryItemNumber
		  
		  from SrcSAP.ZOTC_COSS_SHP as a
			 inner join SrcSAP.LIPS as b
			 on CAST(a.UE_VBELN as int)=CAST(b.VBELN as int) 
			 inner join SrcSAP.LIKP as c
			 on b.VBELN  = c.VBELN
			 where c.WADAT_IST ='00000000'
			 and b.PSTYV between 'Z001' and  'Z009';