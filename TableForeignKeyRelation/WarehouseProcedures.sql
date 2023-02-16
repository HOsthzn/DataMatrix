USE DataMatrix
GO

CREATE OR ALTER FUNCTION dbo.SysForeignKeyRelationExists(@RelationName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT = 0

    SELECT @Result = 1
    FROM sys.foreign_keys
    WHERE name = @RelationName

    RETURN @Result
END
GO

CREATE OR ALTER PROCEDURE CreateForeignKeyRelation(@RelationName NVARCHAR(256), @FromColumn NVARCHAR(128),
                                                   @ToColumn NVARCHAR(128))
AS
BEGIN
    IF dbo.SysForeignKeyRelationExists(@RelationName) = 0
        BEGIN
            -- from table info
            DECLARE @FromSchemaName VARCHAR(256) , @FromTableName VARCHAR(256), @FromColumnName VARCHAR(256);

            SELECT @FromSchemaName = S.Name, @FromTableName = T.Name, @FromColumnName = TC.Name
            FROM dbo.TableColumns AS TC
                     INNER JOIN dbo.Tables AS T ON T.Id = TC.TableId
                     INNER JOIN Schemas AS S ON S.Id = T.SchemaId
            WHERE TC.Id = @FromColumn

            -- to table info
            DECLARE @ToSchemaName VARCHAR(256) ,@ToTableName VARCHAR(256), @ToColumnName VARCHAR(256);

            SELECT @ToSchemaName = S.Name, @ToTableName = T.Name, @ToColumnName = TC.Name
            FROM dbo.TableColumns AS TC
                     INNER JOIN dbo.Tables AS T ON T.Id = TC.TableId
                     INNER JOIN Schemas AS S ON S.Id = T.SchemaId
            WHERE TC.Id = @ToColumn

            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @FromSchemaName + N'.' + @FromTableName +
                                         N' ADD CONSTRAINT ' +
                                         @RelationName + N' FOREIGN KEY (' + @FromColumnName + N') REFERENCES ' +
                                         @ToSchemaName + N'.' + @ToTableName + N' (' + @ToColumnName + N')';

            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.AlterForeignKeyRelation(@RelationName NVARCHAR(256), @FromColumn NVARCHAR(128),
                                                      @ToColumn NVARCHAR(128))
AS
BEGIN

    IF dbo.SysForeignKeyRelationExists(@RelationName) = 1
        BEGIN
            EXEC dbo.DropForeignKeyRelation @RelationName;
            EXEC dbo.CreateForeignKeyRelation @RelationName, @FromColumn, @ToColumn;
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.DropForeignKeyRelation(@RelationName NVARCHAR(256))
AS
BEGIN
    IF dbo.SysForeignKeyRelationExists(@RelationName) = 1
        BEGIN
            DECLARE @FromSchemaName VARCHAR(256) ,@FromTableName VARCHAR(256);

            SELECT @FromSchemaName = S.Name, @FromTableName = T.Name
            FROM dbo.TableForeignKeyRelation AS TFKR
                     INNER JOIN TableColumns AS TC ON TC.Id = TFKR.ForeignColumnId
                     INNER JOIN dbo.Tables AS T ON T.Id = TC.TableId
                     INNER JOIN Schemas AS S ON S.Id = T.SchemaId
            WHERE TFKR.Name = @RelationName;

            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @FromSchemaName + N'.' + @FromTableName +
                                         N' DROP CONSTRAINT ' + @RelationName;

            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
