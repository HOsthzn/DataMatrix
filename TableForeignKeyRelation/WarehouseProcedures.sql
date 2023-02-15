USE DataMatrix
GO

CREATE OR ALTER FUNCTION dbo.SysForeignKeyRelationExists(@RelationName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT

    SELECT @Result = 1
    FROM sys.foreign_key_columns
    WHERE OBJECT_NAME(parent_object_id) = @RelationName

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
            DECLARE @FromTableName VARCHAR(256), @FromColumnName VARCHAR(256);

            SELECT @FromTableName = T.Name, @FromColumnName = TC.Name
            FROM dbo.TableColumns AS TC
                     INNER JOIN dbo.Tables AS T ON T.Id = TC.TableId
            WHERE TC.Id = @FromColumn

            -- to table info
            DECLARE @ToTableName VARCHAR(256), @ToColumnName VARCHAR(256);

            SELECT @ToTableName = T.Name, @ToColumnName = TC.Name
            FROM dbo.TableColumns AS TC
                     INNER JOIN dbo.Tables AS T ON T.Id = TC.TableId
            WHERE TC.Id = @ToColumn

            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @FromTableName + N' ADD CONSTRAINT ' + @RelationName +
                                         N' FOREIGN KEY (' + @FromColumnName + N') REFERENCES ' + @ToTableName + N' (' +
                                         @ToColumnName + N')';

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
            DECLARE @FromTableName VARCHAR(256);

            SELECT @FromTableName = T.Name
            FROM dbo.TableForeignKeyRelation AS TFKR
                     INNER JOIN TableColumns TC ON TC.Id = TFKR.ForeignColumnId
                     INNER JOIN dbo.Tables T ON T.Id = TC.TableId
            WHERE TFKR.Name = @RelationName;

            DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @FromTableName + N' DROP CONSTRAINT ' + @RelationName;

            EXEC [dbo].[ExecuteDynamicSQL] @sql;
        END
END
