CREATE OR ALTER FUNCTION dbo.SysColumnExists(
    @TableId NVARCHAR(128),
    @ColumnName VARCHAR(256)
)
    RETURNS BIT
AS
BEGIN
    DECLARE @SchemaName VARCHAR(256), @TableName VARCHAR(256)

    SELECT @SchemaName = S.Name
         , @TableName = T.Name
    FROM dbo.Tables AS T
             INNER JOIN dbo.Schemas AS S ON S.Id = T.SchemaId
    WHERE T.Id = @TableId

    IF EXISTS(SELECT 1
              FROM sys.columns
              WHERE name = @ColumnName
                AND object_id = OBJECT_ID(QUOTENAME(@SchemaName) + '.' + QUOTENAME(@TableName)))
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

CREATE OR ALTER PROCEDURE dbo.CreateColumn @TableId NVARCHAR(128),
                                           @Name NVARCHAR(128),
                                           @DataTypeId NVARCHAR(128), @NotNull BIT = 0
AS
BEGIN
    IF [dbo].[SysColumnExists](@TableId, @Name) = 0
        BEGIN

            DECLARE @SchemaName VARCHAR(256), @TableName VARCHAR(256)

            SELECT @SchemaName = S.Name
                 , @TableName = T.Name
            FROM dbo.Tables AS T
                     INNER JOIN dbo.Schemas AS S ON S.Id = T.SchemaId
            WHERE T.Id = @TableId;

            DECLARE @sql NVARCHAR(MAX) = IIF(@NotNull = 1,
                                             'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] ADD [' + @Name +
                                             '] ' + dbo.GetSQLDataType(@DataTypeId) + ' DEFAULT ' +
                                             (SELECT DEFAULT FROM dbo.DataTypes WHERE Id = @DataTypeId) + ' NOT NULL;',
                                             'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] ADD [' + @Name +
                                             '] ' + dbo.GetSQLDataType(@DataTypeId) + ' DEFAULT ' +
                                             (SELECT DEFAULT FROM dbo.DataTypes WHERE Id = @DataTypeId) + ';');

            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.AlterColumn @Id nvarchar(128), @TableId NVARCHAR(128),
                                          @Name NVARCHAR(128),
                                          @DataTypeId nvarchar(128) = NULL
AS
BEGIN

    /*ALTER TABLE [].[] ALTER COLUMN name INT NULL;
    EXEC sp_rename 'Test.Test.name', [], 'COLUMN';*/

    EXEC [dbo].[ExecuteDynamicSQL] @sql;
END
GO

CREATE OR ALTER PROCEDURE dbo.DropColumn(@Id NVARCHAR(128))
AS
BEGIN
    DECLARE @SchemaName VARCHAR(256), @TableId NVARCHAR(128), @TableName VARCHAR(256), @ColName VARCHAR(256);
    SELECT @SchemaName = S.Name, @TableName = T.Name, @ColName = TC.Name
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
             INNER JOIN dbo.Schemas AS S ON S.Id = T.SchemaId

    IF [dbo].[SysColumnExists](@TableId, @ColName) = 1
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP COLUMN ' +
                                         @ColName + ';';
            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO
