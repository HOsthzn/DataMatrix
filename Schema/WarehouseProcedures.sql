-- Procedure to create a schema
CREATE PROCEDURE dbo.CreateSchema
(
    @Name VARCHAR(256)
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    DECLARE @Id UNIQUEIDENTIFIER = NEWID();

    EXEC sp_executesql N'CREATE SCHEMA [' + @Name + ']';

    exec dbo.InsertSchema @Name;
END

-- Procedure to rename a schema
CREATE PROCEDURE dbo.RenameSchema
(
    @CurrentName VARCHAR(256),
    @NewName VARCHAR(256)
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    DECLARE @Id UNIQUEIDENTIFIER;

    SELECT @Id = Id
    FROM dbo.Schemas
    WHERE Name = @CurrentName;

    EXEC sp_executesql N'ALTER SCHEMA ' + @CurrentName + ' TRANSFER [' + @NewName + ']';

    exec dbo.UpdateSchema @Id, @NewName;
END

-- Procedure to delete a schema
CREATE PROCEDURE dbo.DeleteSchema
    @Name VARCHAR(256)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    DECLARE @Id UNIQUEIDENTIFIER;

    SELECT @Id = Id
    FROM dbo.Schemas
    WHERE Name = @Name;

    DECLARE @SQL NVARCHAR(MAX) = '';

    SET @SQL = 'DROP SCHEMA ' + @Name;
    EXEC sp_executesql @SQL;

    exec dbo.DeleteSchema @Id
END
