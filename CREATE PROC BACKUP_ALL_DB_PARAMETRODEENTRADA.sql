-- Script Backup BD 


USE master
GO
DROP PROCEDURE IF EXISTS BACKUP_ALL_DB_PARENTRADA
GO

-- SQL Server 2017
-- CREATE OR ALTER 
CREATE PROC BACKUP_ALL_DB_PARENTRADA
	@path VARCHAR(256)
AS
-- Declarando variables
DECLARE @name VARCHAR(50), -- database name
-- @path VARCHAR(256), -- path for backup files
@fileName VARCHAR(256), -- filename for backup
@fileDate VARCHAR(20), -- used for file name
@backupCount INT

CREATE TABLE [dbo].#tempBackup 
(intID INT IDENTITY (1, 1), 
name VARCHAR(200))

-- Crear la Carpeta Backup
-- SET @path = 'C:\Backup\'

-- Includes the date in the filename
SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112)

-- Includes the date and time in the filename
--SET @fileDate = CONVERT(VARCHAR(20), GETDATE(), 112) + '_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 108), ':', '')

INSERT INTO [dbo].#tempBackup (name)
	SELECT name
	FROM master.dbo.sysdatabases
	WHERE name in ( 'Northwind','pubs')
-- WHERE name NOT IN ('master', 'model', 'msdb', 'tempdb')

SELECT TOP 1 @backupCount = intID 
FROM [dbo].#tempBackup 
ORDER BY intID DESC

-- Utilidad: Solo Comprobación Nº Backups a realizar
print @backupCount

IF ((@backupCount IS NOT NULL) AND (@backupCount > 0))
BEGIN
	DECLARE @currentBackup INT
	SET @currentBackup = 1
	WHILE (@currentBackup <= @backupCount)
		BEGIN
			SELECT
				@name = name,
				@fileName = @path + name + '_' + @fileDate + '.BAK' -- Unique FileName
				--@fileName = @path + @name + '.BAK' -- Non-Unique Filename
				FROM [dbo].#tempBackup
				WHERE intID = @currentBackup

			-- Utilidad: Solo Comprobación Nombre Backup
			print @fileName

			-- does not overwrite the existing file
				BACKUP DATABASE @name TO DISK = @fileName
			-- overwrites the existing file (Note: remove @fileDate from the fileName so they are no longer unique
			--BACKUP DATABASE @name TO DISK = @fileName WITH INIT

				SET @currentBackup = @currentBackup + 1
		END
END

-- Utilidad: Solo Comprobación Mirar panel de Resultados Autonumerico y Nombre BD
SELECT * FROM [dbo].#tempBackup
-- 
DROP TABLE [dbo].#tempBackup

GO


-- Ejecutar Procedimiento
-- Input Parameter 'C:\Backup\'
EXEC BACKUP_ALL_DB_PARENTRADA 'C:\Backup\'
GO

-- Outcome

-- Results

--intID	name
--1	Northwind
--2	pubs


-- Messages

--(2 row(s) affected)
--2
--C:\Backup\Northwind_20180925.BAK
--Processed 816 pages for database 'Northwind', file 'Northwind' on file 1.
--Processed 3 pages for database 'Northwind', file 'Northwind_log' on file 1.
--BACKUP DATABASE successfully processed 819 pages in 4.682 seconds (1.365 MB/sec).
--C:\Backup\pubs_20180925.BAK
--Processed 600 pages for database 'pubs', file 'pubs' on file 1.
--Processed 3 pages for database 'pubs', file 'pubs_log' on file 1.
--BACKUP DATABASE successfully processed 603 pages in 1.826 seconds (2.576 MB/sec).

--(2 row(s) affected)

-- Check Out
-- Folder C:\Backup\


-------------------------------------------------------------------------------

-- DBCC CLONEDATABASE

-- https://support.microsoft.com/en-us/help/3177838/how-to-use-dbcc-clonedatabase-to-generate-a-schema-and-statistics-only
-- https://docs.microsoft.com/es-es/sql/t-sql/database-console-commands/dbcc-clonedatabase-transact-sql?view=sql-server-2017

--Check the current database 

DBCC CHECKDB;
GO

DBCC CHECKDB (AdventureWorks2017);
GO

--Check the Adventureworks2017 without nonclustedred indexes
DBCC CHECKDB (AdventureWorks2017, NOINDEX);
GO



-- Generate the clone of Pubs database.    
DBCC CLONEDATABASE (Pubs, Pubs_Clone);    
GO 

-- SQL Server 2016 without service pack 

--Msg 2526, Level 16, State 3, Line 116
--Incorrect DBCC statement. Check the documentation for the correct DBCC syntax and options.


--Crear un clon de una base de datos que se comprueba para su uso en producción que incluye una copia de seguridad de la base de datos clonada
--En el ejemplo siguiente se crea un clon de solo esquema de la base de datos AdventureWorks sin datos de estadísticas ni de almacén de consultas que se comprueba para su uso como base de datos de producción. También se creará una copia de seguridad comprobada de la base de datos clonada ( SQL Server 2016 (13.x) SP2 y versiones posteriores).

DBCC CLONEDATABASE (AdventureWorks2014, AdventureWorks_Clone) WITH VERIFY_CLONEDB, BACKUP_CLONEDB;    
GO

