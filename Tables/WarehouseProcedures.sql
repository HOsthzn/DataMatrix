CREATE OR ALTER FUNCTION dbo.SysTableExists(@SchemaId NVARCHAR(128), @TableName VARCHAR(256))
    RETURNS BIT
AS
BEGIN
    DECLARE @SchemaName VARCHAR(256)

    SELECT @SchemaName = Name
    FROM dbo.Schemas
    WHERE Id = @SchemaId

    IF EXISTS(SELECT 1
              FROM sys.tables
              WHERE name = @TableName
                AND SCHEMA_NAME(schema_id) = @SchemaName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO



CREATE OR ALTER PROCEDURE dbo.CreateTable(
    @SchemaId NVARCHAR(128),
    @Name VARCHAR(256)
)
AS
BEGIN
    IF dbo.SysTableExists(@SchemaId, @Name) = 0
        BEGIN
            DECLARE @SchemaName VARCHAR(256);
            SELECT @SchemaName = Name
            FROM dbo.Schemas
            WHERE Id = @SchemaId
            DECLARE @sql NVARCHAR(MAX) = N'CREATE TABLE [' + @SchemaName + '].[' + @Name +
                                         '] (Id INT NOT NULL CONSTRAINT ' + @SchemaName + '_' + @Name +
                                         '_pk PRIMARY KEY)';
            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.RenameTable(@TableId VARCHAR(256), @NewName VARCHAR(256))
AS
BEGIN
    DECLARE @SchemaName VARCHAR(256), @SchemaId NVARCHAR(128), @OldName VARCHAR(256);
    SELECT @SchemaName = S.Name
         , @SchemaId = T.SchemaId
         , @OldName = T.Name
    FROM dbo.Tables AS T
             INNER JOIN Schemas AS S ON S.Id = T.SchemaId

    IF dbo.SysTableExists(@SchemaId, @NewName) = 0
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = N'EXEC sp_rename ''' + @SchemaName + '.' + @OldName + ''', ''' + @NewName +
                                         ''' , ''OBJECT'' ';
            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.DropTable(@TableId NVARCHAR(128))
AS
BEGIN
    DECLARE @SchemaName VARCHAR(256), @SchemaId NVARCHAR(128), @TableName VARCHAR(256);
    SELECT @SchemaName = S.Name
         , @SchemaId = T.SchemaId
         , @TableName = T.Name
    FROM dbo.Tables AS T
             INNER JOIN Schemas AS S ON S.Id = T.SchemaId
    IF dbo.SysTableExists(@SchemaId, @TableName) = 0
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = N'DROP TABLE [' + @SchemaName + '].[' + @TableName + ']';
            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO
