CREATE VIEW [TABSAP].[DimCompany] AS SELECT [BUKRS] as [Company Code],
		[BUTXT] as [Company Code Text],
		[KTOPL]as [Chart of Accounts],
		[RCOMP] as [Company],
		[LAND1] as [Country Key],
		[WAERS] as [Currency Key],
		[KKBER] as [Credit control area],
		[PERIV] as [Fiscal Year Variant],
		[Level1]as [Level 1],
		[Level2]as [Level 2],
		Cast(Level2Sort as  int) as level2Sort,
		 [Level3]as [Level 3],
		Cast (level3sort as INT) as level3Sort,
		 [Level4]as [Level 4],
		CAST  (Level4sort as INT) as level4Sort,
		[Level5]as [Level 5],
		CAST (Level5Sort as int) as level5sort,
		[Level6]as [Level 6],
		CAst(level6Sort as int) as level6Sort,
		[Level7]as [Level 7],
		CAst(level7Sort as int) as level7Sort,
		[Level8]as [Level 8],
		CAst(level8Sort as int) as level8Sort
	FROM [SrcSAP].[T001]
	INNER JOIN SrcSAPFile.CompCodeHier ON [SrcSAP].[T001].[BUKRS] = SrcSAPFile.CompCodeHier.[CompanyCode]
	
/*BI - 11264*/
UNION

SELECT [CompanyCode] as [Company Code],
		' ' as [Company Code Text],
		' ' as [Chart of Accounts],
		' ' as [Company],
		' ' as [Country Key],
		' ' as [Currency Key],
		' ' as [Credit control area],
		' ' as [Fiscal Year Variant],
		[Level1]as [Level 1],
		[Level2]as [Level 2],
		Cast(Level2Sort as  int) as level2Sort,
		 [Level3]as [Level 3],
		Cast (level3sort as INT) as level3Sort,
		 [Level4]as [Level 4],
		CAST  (Level4sort as INT) as level4Sort,
		[Level5]as [Level 5],
		CAST (Level5Sort as int) as level5sort,
		[Level6]as [Level 6],
		CAst(level6Sort as int) as level6Sort,
		[Level7]as [Level 7],
		CAst(level7Sort as int) as level7Sort,
		[Level8]as [Level 8],
		CAst(level8Sort as int) as level8Sort
	FROM SrcSAPFile.CompCodeHier
	WHERE CompanyCode like 'E_%' OR CompanyCode = 'CSO';