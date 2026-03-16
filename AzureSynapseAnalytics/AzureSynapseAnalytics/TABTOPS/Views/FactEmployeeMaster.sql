CREATE VIEW [TABTOPS].[FactEmployeeMaster] AS   WITH rolling13months AS 
( 
       SELECT skdate, 
              [Date], 
              calendarmonth, 
              calendaryear 
       FROM   dw.dimdate 
       WHERE  calendarday=1 
       AND    [Date]>Dateadd(month,-24,Getdate()) 
       AND    [Date]<Getdate() 
              
) ,employeemaster AS 
( 
           SELECT     a.[HireDate], 
					  a.OriginalHireDate,
                      a.activestatus, 
                      a.terminationdate, 
                      a.[Location], 
                      b.[KeyPlant],
                      a.[Emc],
                      a.[WorkerType],
                      a.[jobCategory],
					  a.CostCenter,
					  a.IsRehire,
					  a.EmailWork,
					  Row_Number() Over(Partition by EmployeeID,WorkerType Order by ADLSTimestamp DESC ) AS RNUM
           FROM       [SrcWorkday].[EmployeeMaster]       AS a 
           INNER JOIN [SrcWorkday].[LocationPlantMapping] AS b 
           ON         b.[HRPlantDescription]=a.[Location] 
                  
) , HC_Metric AS 
( 
          SELECT  m.skdate as SKDate, 
                  m.[Date], 
                  e.[KeyPlant] , 
				  SUM(
				      CASE WHEN e.HireDate  <= Cast(m.[Date] AS DATETIME) THEN 1 
                           ELSE 0 END					  
				     ) AS Joiners
					 ,
				  SUM(
				      CASE WHEN e.OriginalHireDate  <= Cast(m.[Date] AS DATETIME) and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS Rehires,
				  SUM(
				      CASE WHEN e.terminationdate IS NULL THEN 0 
					       WHEN (Cast(e.terminationdate AS DATETIME)+1)  <= Cast(m.[Date] AS DATETIME) THEN 1 
                           ELSE 0 END			  
				     ) AS Leavers
					 ,
				  SUM(
				      CASE WHEN e.HireDate > e.OriginalHireDate and e.terminationdate > e.HireDate and e.terminationdate <= Cast(m.[Date] AS DATETIME)  and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS RehireTerms


         FROM     rolling13months AS m , 
                  employeemaster  AS e 
				  WHERE e.RNUM =1  and ((emc = 'Emory Wright' AND [WorkerType] = 'Employee' ) OR (emc = 'Stuart Hockridge'  and EmailWork ='noemailjz@aligntech.com') )
         GROUP BY m.skdate, 
                  m.[Date], 
                  e.[KeyPlant]
), final AS 
( 
         SELECT   m.skdate as SKDate, 
                  m.[Date], 
                  e.[KeyPlant], 
               --   Row_number() OVER (partition BY e.[KeyPlant] ORDER BY m.[Date]) AS rnumber, 
				  SUM(
				      CASE WHEN DATEADD(month, DATEDIFF(month, 0, e.HireDate), 0)  <= Cast(m.[Date] AS DATETIME) THEN 1 
                           ELSE 0 END					  
				     ) AS Joiners,
				  SUM(
				      CASE WHEN DATEADD(month, DATEDIFF(month, 0, e.OriginalHireDate), 0)  <= Cast(m.[Date] AS DATETIME) and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS Rehires,
				  SUM(
				      CASE WHEN e.terminationdate IS NULL THEN 0 
					       WHEN DATEADD(month, DATEDIFF(month, 0, Cast(e.terminationdate AS DATETIME)+1 ), 0)   <= Cast(m.[Date] AS DATETIME) THEN 1 
                           ELSE 0 END			  
				     ) AS Leavers,
				  SUM(
				      CASE WHEN e.HireDate > e.OriginalHireDate and e.terminationdate > e.HireDate and DATEADD(month, DATEDIFF(month, 0, e.terminationdate), 0) <= Cast(m.[Date] AS DATETIME)  and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS RehireTerms,
				  SUM(
				      CASE WHEN DATEADD(month, DATEDIFF(month, 0, e.HireDate), 0)  <= DATEADD(Month,-12,Cast(m.[Date] AS DATETIME)) THEN 1 
                           ELSE 0 END					  
				     ) AS Joiners12,
				  SUM(
				      CASE WHEN DATEADD(month, DATEDIFF(month, 0, e.OriginalHireDate), 0)  <= DATEADD(Month,-12,Cast(m.[Date] AS DATETIME)) and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS Rehires12,
				  SUM(
				      CASE WHEN e.terminationdate IS NULL THEN 0 
					       WHEN DATEADD(month, DATEDIFF(month, 0, Cast(e.terminationdate AS DATETIME)+1 ), 0)   <= DATEADD(Month,-12,Cast(m.[Date] AS DATETIME)) THEN 1 
                           ELSE 0 END			  
				     ) AS Leavers12,
				  SUM(
				      CASE WHEN e.HireDate > e.OriginalHireDate and e.terminationdate > e.HireDate and DATEADD(month, DATEDIFF(month, 0, e.terminationdate), 0) <= DATEADD(Month,-12,Cast(m.[Date] AS DATETIME))  and e.IsRehire =1 THEN 1 
                           ELSE 0 END			  
				     ) AS RehireTerms12,
				  Sum( 
                  CASE      
                           WHEN m.[Date] BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalActiveEmployees, 
				  Sum( 
                  CASE      
                           WHEN DATEADD(Month,-12,m.[Date])	 BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalActiveEmployees12,
                  Sum( 
                  CASE   
                           WHEN  Month(e.terminationdate) = m.[CalendarMonth] 
                           AND      Year(e.terminationdate) = m.[CalendarYear] THEN 1 
                           ELSE 0 
                 END)            AS TotalTerminatedEmployees,

 

                  Sum( 
                  CASE      
                           WHEN  e.jobCategory = 'Direct' 
                                and m.[Date] BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalDirectActiveEmployees,
                  Sum( 
                  CASE      
                           WHEN  e.jobCategory = 'Direct' 
                                and DATEADD(Month,-12,m.[Date]) BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalDirectActiveEmployees12,
				  Sum( 
                  CASE      
                           WHEN  e.jobCategory = 'Direct' 
								and e.CostCenter in ('10035 SLA - 2802','10036 A Fab - 2802','10069 A Fab - 2802 NA')
                                and m.[Date] BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalDirectActiveEmployeesAMER,


				  Sum( 
                  CASE      
                           WHEN  e.jobCategory = 'Direct' 
								and e.CostCenter in ('10002 SLA - 2801','10003 A Fab - 2801')
                                and m.[Date] BETWEEN e.[HireDate] AND  Isnull( 
                                    CASE 
                                             WHEN e.activestatus =1 THEN NULL 
                                             ELSE e.terminationdate 
                                    END,'2099-01-01') THEN 1 
                           ELSE 0 
                  END) AS TotalDirectActiveEmployees_EMEA_APAC
         FROM     rolling13months AS m , 
                  employeemaster  AS e 
		 WHERE e.RNUM =1  and ((emc = 'Emory Wright' AND [WorkerType] = 'Employee' ) OR (emc = 'Stuart Hockridge'  and EmailWork ='noemailjz@aligntech.com') )
         GROUP BY m.skdate, 
                  m.[Date], 
                  e.[KeyPlant] 
) 

SELECT  
		F.SKDate,
		F.[Date],
		F.[KeyPlant],
		(CAST((F.Joiners+F.Rehires-F.Leavers-F.RehireTerms) AS FLOAT)  + CAST((H.Joiners+H.Rehires-H.Leavers-H.RehireTerms) AS FLOAT) ) /2 AS AvgHCCal,
		TotalActiveEmployees,
		TotalTerminatedEmployees,
		TotalDirectActiveEmployees,		
		TotalDirectActiveEmployeesAMER,
		TotalDirectActiveEmployees_EMEA_APAC,
		(CAST(TotalActiveEmployees AS FLOAT) + CAST(TotalActiveEmployees12 AS FLOAT)) /2 AS Rolling12MonthActiveEmployeesAvg,
		sum(TotalTerminatedEmployees) OVER (partition BY F.[KeyPlant] ORDER BY F.[Date] rows BETWEEN 11 PRECEDING AND      CURRENT row) AS Rolling12MonthTerminatedEmployees,
		(CAST(TotalDirectActiveEmployees AS FLOAT) + CAST(TotalDirectActiveEmployees12 AS FLOAT)) /2 AS Rolling12MonthDirectActiveEmployeesAvg,
		(CAST((F.Joiners+F.Rehires-F.Leavers-F.RehireTerms) AS FLOAT)  + CAST((F.Joiners12+F.Rehires12-F.Leavers12-F.RehireTerms12) AS FLOAT) ) /2 AS Rolling12MonthHCCal
FROM final F
LEFT JOIN HC_Metric H ON F.SKDate = H.SKDate and F.KeyPlant = H.KeyPlant;