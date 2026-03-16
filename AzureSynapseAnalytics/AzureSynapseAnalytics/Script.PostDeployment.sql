/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
declare @dbname varchar(100) = (db_name())
DECLARE @stat_off NVARCHAR(MAX) = ('Alter Database ['+@dbname+'] SET AUTO_CREATE_STATISTICS ON');
print @stat_off
EXEC sp_executesql @stat_off;