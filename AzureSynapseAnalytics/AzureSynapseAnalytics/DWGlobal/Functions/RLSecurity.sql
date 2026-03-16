CREATE FUNCTION [DWGlobal].[RLSecurity] (@Region [sysname]) RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN SELECT 1 AS fn_result
WHERE is_member('BI-DW-'+@Region)=1 or is_member('BI-DW-'+substring(@Region,0,charindex('-',@Region))+'-ReadAll')=1 or is_member('ReadAll')=1 or is_member('BI-DW-'+substring(@Region,0,charindex('-',@Region))+'-Global')=1