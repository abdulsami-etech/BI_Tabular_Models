CREATE VIEW [SrcInst].[DimInstSession]
AS SELECT 
[session_id]
,[ADLSTimeStamp]
,[wand_version]
      ,[rx_id]
      ,[scan_date]
      ,[case_type]
      ,[firewall_info_1]
      ,[still_time_in_seconds]
      ,[SessionTime]
      ,[doctor_name]
      ,[occlusionColors]
      ,[computer_name]
      ,[crown_install_date]
      ,[wand_id]
      ,[company_id]
      ,[doctor_id]
      ,[internet_explorer_version]
      ,[instrumentation_case_id]
      ,[case_type (id)]
      ,[is_online_mode]
 FROM   
(
   SELECT 
        session_id, adlstimestamp,
        [Name],
		[Value]
	    FROM 
        srcinst.Session_ext
		where 	 
		name in (
       'wand_version'
      ,'rx_id'
      ,'scan_date'
      ,'case_type'
      ,'firewall_info_1'
      ,'still_time_in_seconds'
      ,'SessionTime'
      ,'doctor_name'
      ,'occlusionColors'
      ,'computer_name'
      ,'crown_install_date'
      ,'wand_id'
      ,'company_id'
      ,'doctor_id'
      ,'internet_explorer_version'
      ,'instrumentation_case_id'
	  ,'case_type (id)'
      ,'is_online_mode')
	 ) t 
PIVOT(
    Max([Value]) 
    FOR [name] IN (
       [wand_version]
      ,[rx_id]
      ,[scan_date]
      ,[case_type]
      ,[firewall_info_1]
      ,[still_time_in_seconds]
      ,[SessionTime]
      ,[doctor_name]
      ,[occlusionColors]
      ,[computer_name]
      ,[crown_install_date]
      ,[wand_id]
      ,[company_id]
      ,[doctor_id]
      ,[internet_explorer_version]
      ,[instrumentation_case_id]
      ,[case_type (id)]
      ,[is_online_mode])
) AS pivot_table;