USE DataMatrix
GO

-- Procedure to check if a table column exists
CREATE OR ALTER FUNCTION dbo.ForeignKeyRelationExists(@RelationName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM dbo.TableForeignKeyRelation
              WHERE Name = @RelationName
                 OR Id = @RelationName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

CREATE OR ALTER FUNCTION dbo.GetForeignKeyRelationId(@FromColumn NVARCHAR(128), @ToColumn NVARCHAR(128))
    RETURNS NVARCHAR(128)
AS
BEGIN
    DECLARE @Result NVARCHAR(128) = NULL
    SELECT TOP (1) @Result = Id
    FROM dbo.TableForeignKeyRelation
    WHERE ForeignColumnId = @FromColumn
      AND PrimaryColumnId = @ToColumn

    RETURN @Result;
END
GO

CREATE OR ALTER FUNCTION dbo.GetForeignKeyRelationName(@FromColumn NVARCHAR(128), @ToColumn NVARCHAR(128))
    RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @Result VARCHAR(256);

    SELECT @Result = CONCAT(FT.Name, '_', FTC.Name, '_', PT.Name, '_', PTC.Name, '_fk')
    FROM TableForeignKeyRelation AS TFKR
             INNER JOIN dbo.TableColumns AS FTC ON FTC.Id = TFKR.ForeignColumnId
             INNER JOIN dbo.Tables AS FT ON FT.Id = FTC.TableId
             INNER JOIN dbo.TableColumns AS PTC ON FTC.Id = TFKR.PrimaryColumnId
             INNER JOIN dbo.Tables AS PT ON PT.Id = PTC.TableId
    RETURN @Result;
END
GO

CREATE OR ALTER PROCEDURE InsertTableForeignKeyRelation(@FromColumn NVARCHAR(128), @ToColumn NVARCHAR(128),
                                                        @Id NVARCHAR(128) OUTPUT)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    DECLARE @Name VARCHAR(256) = dbo.GetForeignKeyRelationName(@FromColumn, @ToColumn)
    -- TODO call CreateFK procedure
    IF dbo.ForeignKeyRelationExists(@Name) = 0
        BEGIN
            SET @Id = NEWID();

            INSERT INTO dbo.TableForeignKeyRelation (Id, Name, ForeignColumnId, PrimaryColumnId, AlterDate)
            VALUES (@Id, @Name, @FromColumn, @ToColumn, @CurrentDate)
        END
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE UpdateTableForeignKeyRelation(@Id NVARCHAR(128), @FromColumn NVARCHAR(128),
                                                        @ToColumn NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    -- TODO call AlterFK procedure
    IF dbo.ForeignKeyRelationExists(@Id) = 1
        BEGIN
            UPDATE dbo.TableForeignKeyRelation
            SET Name            = dbo.GetForeignKeyRelationName(@FromColumn, @ToColumn)
              , ForeignColumnId = @FromColumn
              , PrimaryColumnId = @ToColumn
              , AlterDate       = @CurrentDate
            WHERE Id = @Id
        END
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE DeleteTableForeignKeyRelation(@Id NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    -- TODO call DropFK procedure
    IF dbo.ForeignKeyRelationExists(@Id) = 1
        BEGIN
            DELETE
            FROM dbo.TableForeignKeyRelation
            WHERE Id = @Id
        END
    COMMIT;
END
GO