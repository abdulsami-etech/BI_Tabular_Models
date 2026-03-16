CREATE PROC [CTRL].[GetLastRowCount] @Label [varchar](200),@rc [bigint] OUT AS
begin
	select top (1) @rc = row_count
	from sys.dm_pdw_request_steps
	where row_count >= 0
	and status != 'running'
	and request_id in (
		select top (1) request_id
		from sys.dm_pdw_exec_requests
		where session_id = session_id()
		and [label] = @Label
		and status != 'running'
		order by end_time desc
	)
	order by end_time desc

end
