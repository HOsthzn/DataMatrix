USE DataMatrix
GO

-- Check if the schema already exists
CREATE OR ALTER FUNCTION dbo.SchemaExists(@SchemaName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM dbo.Schemas
              WHERE name = @SchemaName
                 OR Id = @SchemaName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

CREATE OR ALTER PROCEDURE dbo.InsertSchema(
    @Name VARCHAR(256)
)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    EXEC dbo.CreateSchema @Name;
    IF dbo.SchemaExists(@Name) = 0
        BEGIN
            INSERT INTO dbo.Schemas (Id, Name, AlterDate)
            VALUES (NEWID(), @Name, @CurrentDate)
        END
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateSchema(
    @Id NVARCHAR(128),
    @Name VARCHAR(256)
)
AS
BEGIN
    BEGIN TRANSACTION ;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    EXECUTE dbo.RenameSchema @Id, @Name;
    IF dbo.SchemaExists(@Name) = 0
        BEGIN
            UPDATE dbo.Schemas
            SET Name      = @Name
              , AlterDate = @CurrentDate
            WHERE Id = @Id
        END
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteSchema(
    @Id NVARCHAR(128)
)
AS
BEGIN
    BEGIN TRANSACTION;
    EXECUTE dbo.DropSchema @Id;
    IF dbo.SchemaExists(@Id) = 0
        BEGIN
            DELETE
            FROM dbo.Schemas
            WHERE Id = @Id
        END
    COMMIT;
END
GO