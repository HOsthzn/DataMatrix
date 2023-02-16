USE DataMatrix
GO

CREATE OR ALTER FUNCTION dbo.SysSchemaExists(@SchemaName VARCHAR(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM sys.schemas
              WHERE name = @SchemaName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateSchema(
    @Name VARCHAR(256)
)
AS
BEGIN
    IF dbo.SysSchemaExists(@Name) = 0
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'CREATE SCHEMA [' + @Name + ']';
            EXEC dbo.ExecuteDynamicSQL @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateSchemaAudit(@Name VARCHAR(256)) AS
BEGIN
    SET @Name = CONCAT(@Name, '_Audit')
    EXEC dbo.CreateSchema @Name
END
GO

CREATE OR ALTER PROCEDURE dbo.RenameSchema(
    @Id NVARCHAR(128),
    @NewName VARCHAR(256)
)
AS
BEGIN
    DECLARE @OldName VARCHAR(256);

    SELECT @OldName = Name
    FROM dbo.Schemas
    WHERE Id = @Id;

    IF @OldName IS NOT NULL AND @OldName <> @NewName AND dbo.SysSchemaExists(@NewName) = 1
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'EXEC sys.sp_rename @objname = ''[' + @OldName + ']'', @newname = ''' +
                                         @NewName + ''', ''DATABASE'';';
            EXEC dbo.ExecuteDynamicSQL @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.RenameSchemaAudit(@Id NVARCHAR(128), @NewName VARCHAR(256)) AS
BEGIN
    SET @NewName = CONCAT(@NewName, '_Audit')
    EXEC dbo.RenameSchema @Id, @NewName
END
GO

CREATE OR ALTER PROCEDURE dbo.DropSchema(@Id NVARCHAR(128))
AS
BEGIN
    DECLARE @Name VARCHAR(256);

    SELECT @Name = Name
    FROM dbo.Schemas
    WHERE Id = @Id;

    IF dbo.SysSchemaExists(@Name) = 1
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'DROP SCHEMA [' + @Name + ']';
            EXEC dbo.ExecuteDynamicSQL @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.DropSchemaAudit(@Id NVARCHAR(128)) AS
BEGIN
    DECLARE @Name VARCHAR(256)
    SELECT @Name = CONCAT(Name, '_Audit')
    FROM dbo.Schemas
    WHERE Id = @Id;

    DECLARE @sql NVARCHAR(MAX) = 'DROP SCHEMA [' + @Name + ']';
    EXEC dbo.ExecuteDynamicSQL @sql;
END