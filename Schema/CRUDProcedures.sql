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
    @Name VARCHAR(256), @Id NVARCHAR(128) OUTPUT
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    IF dbo.SchemaExists(@Name) = 0
        BEGIN
            SET @Id = NEWID();
            INSERT INTO dbo.Schemas (Id, Name, AlterDate)
            VALUES (@Id, @Name, @CurrentDate)
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.UpdateSchema(
    @Id NVARCHAR(128),
    @Name VARCHAR(256)
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    IF dbo.SchemaExists(@Name) = 0
        BEGIN
            UPDATE dbo.Schemas
            SET Name      = @Name
              , AlterDate = @CurrentDate
            WHERE Id = @Id
        END
END
GO

CREATE OR ALTER PROCEDURE dbo.DeleteSchema(
    @Id NVARCHAR(128)
)
AS
BEGIN
    IF dbo.SchemaExists(@Id) = 1
        BEGIN
            DELETE
            FROM dbo.Schemas
            WHERE Id = @Id
        END
END
GO