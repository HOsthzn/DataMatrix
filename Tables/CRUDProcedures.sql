CREATE OR ALTER FUNCTION dbo.TableExists(@SchemaId NVARCHAR(128), @TableName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM dbo.Tables
              WHERE SchemaId = @SchemaId
                  AND Name = @TableName
                 OR Id = @TableName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

-- Procedure to insert a table
CREATE OR ALTER PROCEDURE dbo.InsertTable(
    @SchemaId NVARCHAR(128),
    @Name VARCHAR(256),
    @WithAudits BIT = 1
)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    EXECUTE dbo.CreateTable @SchemaId, @Name, @WithAudits;
    IF dbo.TableExists(@SchemaId, @Name) = 0
        BEGIN
            INSERT INTO dbo.Tables (Id, SchemaId, Name, WithAudits, AlterDate)
            VALUES (NEWID(), @SchemaId, @Name, @WithAudits, @CurrentDate);
        END
    COMMIT;
END
GO

-- Procedure to update a table
CREATE OR ALTER PROCEDURE dbo.UpdateTable(
    @Id NVARCHAR(128),
    @SchemaId NVARCHAR(128),
    @Name VARCHAR(256),
    @WithAudits BIT
)
AS
BEGIN
    BEGIN TRANSACTION ;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    EXEC dbo.RenameTable @Id, @Name;
    IF dbo.TableExists(@SchemaId, @Name) = 1
        BEGIN
            UPDATE dbo.Tables
            SET Name       = @Name
              , SchemaId   = @SchemaId
              , WithAudits = @WithAudits
              , AlterDate  = @CurrentDate
            WHERE Id = @Id;
        END
    COMMIT;
END
GO

-- Procedure to delete a table
CREATE OR ALTER PROCEDURE dbo.DeleteTable(
    @SchemaId NVARCHAR(128), @Id NVARCHAR(128)
)
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.DropTable @Id;
    IF dbo.TableExists(@SchemaId, @Id) = 1
        BEGIN
            DELETE
            FROM dbo.Tables
            WHERE Id = @Id;
        END
    COMMIT;
END
GO
