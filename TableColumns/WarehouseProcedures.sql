USE DataMatrix
GO

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

CREATE OR ALTER PROCEDURE dbo.CreateColumn(@TableId NVARCHAR(128), @Name NVARCHAR(128),
                                           @DataTypeId NVARCHAR(128), @Default NVARCHAR(MAX) = NULL, @NotNull BIT = 0)
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

            DECLARE @sql NVARCHAR(MAX);

            SET @sql = CONCAT('ALTER TABLE [', @SchemaName, '].[', @TableName, '] ADD [',
                              @Name, '] ', dbo.GetSQLDataType(@DataTypeId),
                              IIF(@Default IS NULL, '', CONCAT(' DEFAULT ', @Default)),
                              IIF(@NotNull = 0, '', ' NOT NULL'), ';');

            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.AlterColumn(@Id NVARCHAR(128), @TableId NVARCHAR(128),
                                          @Name NVARCHAR(128), @Default NVARCHAR(MAX) = NULL,
                                          @DataTypeId NVARCHAR(128) = NULL, @NotNull BIT = 0)
AS
BEGIN
    IF [dbo].[SysColumnExists](@TableId, @Name) = 1
        BEGIN

            DECLARE @SchemaName VARCHAR(256), @TableName VARCHAR(256)

            SELECT @SchemaName = S.Name
                 , @TableName = T.Name
            FROM dbo.Tables AS T
                     INNER JOIN dbo.Schemas AS S ON S.Id = T.SchemaId
            WHERE T.Id = @TableId;

            DECLARE @sql NVARCHAR(MAX), @Rename BIT = 0, @OldName VARCHAR(256);

            SELECT @Rename = IIF(@Name <> Name, 1, 0), @OldName = Name FROM dbo.TableColumns WHERE Id = @Id

            SET @sql = CONCAT('ALTER TABLE [', QUOTENAME(@SchemaName), '].[', QUOTENAME(@TableName),
                              '] ALTER COLUMN [',
                              QUOTENAME(@Name), '] ', dbo.GetSQLDataType(@DataTypeId),
                              IIF(@Default IS NULL, '', CONCAT(' DEFAULT ', QUOTENAME(@Default))),
                              IIF(@NotNull = 0, '', ' NOT NULL'), ';');

            IF @Rename = 1
                BEGIN
                    DECLARE @fullName VARCHAR(256) = CONCAT(@SchemaName, '.', @TableName, '.', @OldName)
                    SET @sql = CONCAT(@sql, 'EXEC sp_rename ''', @fullName, ''' , ''', @Name, ''', ''COLUMN'' ;')
                END

            EXEC [dbo].[ExecuteDynamicSQL] @sql;

        END
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
    WHERE TC.Id = @Id;

    IF [dbo].[SysColumnExists](@TableId, @ColName) = 1
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'ALTER TABLE [' + @SchemaName + '].[' + @TableName + '] DROP COLUMN ' +
                                         @ColName + ';';
            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO