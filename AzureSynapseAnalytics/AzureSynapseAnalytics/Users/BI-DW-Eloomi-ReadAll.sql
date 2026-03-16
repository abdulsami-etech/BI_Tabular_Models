create user [BI-DW-Eloomi-ReadAll] FROM EXTERNAL PROVIDER
GO
grant select on schema::srcEloomi to [BI-DW-Eloomi-ReadAll] 
