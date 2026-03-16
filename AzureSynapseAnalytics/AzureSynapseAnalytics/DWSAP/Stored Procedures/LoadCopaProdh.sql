CREATE PROC [DWSAP].[LoadCopaProdh] AS 
	
	-- Here we are updating the Product Hierarchy on the bases of the Cost Element 
	--  Here we are specifically updating on the basis of the Product Hierarchy that is 'A1A1N102'
	-- With other conditions such as the BUDAT
	UPDATE DWSAP.FactCOPATranspose  SET
	PRODH = HIGH FROM
	[SrcSAPFile].[BackendVarConfig]
	WHERE CONCAT('0000',[SrcSAPFile].[BackendVarConfig].LOW) = DWSAP.FactCOPATranspose.KSTAR
	AND [SrcSAPFile].[BackendVarConfig].NAME =  'ZBW_COPA'
	AND [SrcSAPFile].[BackendVarConfig].PURPOSE =  DWSAP.FactCOPATranspose.PRODH
	AND DWSAP.FactCOPATranspose.BUDAT	BETWEEN  '19000101' AND '20180731'
	AND DWSAP.FactCOPATranspose.BUDAT	< '20170101' AND PRODH = 'A1A1N102'
	/*JIRA*/
	-- Here we are updating the Product Hierarchy on the bases of the Cost Element 
	--  Here we are specifically updating on the basis of the Product Hierarchy that is not 'A1A1N102'
	-- With other conditions such as the BUDAT
	UPDATE DWSAP.FactCOPATranspose  SET
	PRODH = HIGH FROM
	[SrcSAPFile].[BackendVarConfig]
	WHERE CONCAT('0000',[SrcSAPFile].[BackendVarConfig].LOW) = DWSAP.FactCOPATranspose.KSTAR
	AND [SrcSAPFile].[BackendVarConfig].NAME =  'ZBW_COPA'
	AND [SrcSAPFile].[BackendVarConfig].PURPOSE =  DWSAP.FactCOPATranspose.PRODH
	AND DWSAP.FactCOPATranspose.BUDAT	BETWEEN  '19000101' AND '20180731' AND PRODH <> 'A1A1N102';
