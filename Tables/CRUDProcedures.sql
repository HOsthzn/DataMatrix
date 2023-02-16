USE DataMatrix
GO

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

CREATE OR ALTER PROCEDURE dbo.InsertTable(
    @SchemaId NVARCHAR(128),
    @Name VARCHAR(256),
    @WithAudits BIT = 1,
    @Id NVARCHAR(128) OUTPUT
)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    EXECUTE dbo.CreateTable @SchemaId, @Name;
    IF @WithAudits = 1
        EXECUTE dbo.CreateTableAudit @SchemaId, @Name;
    IF dbo.TableExists(@SchemaId, @Name) = 0
        BEGIN
            SET @Id = NEWID();

            INSERT INTO dbo.Tables (Id, SchemaId, Name, WithAudits, AlterDate)
            VALUES (@Id, @SchemaId, @Name, @WithAudits, @CurrentDate);
        END
    COMMIT;
END
GO

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
    IF @WithAudits = 1
        EXEC dbo.RenameTableAudit @Id, @Name;
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

CREATE OR ALTER PROCEDURE dbo.DeleteTable(
    @SchemaId NVARCHAR(128), @Id NVARCHAR(128)
)
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.DropTable @Id;

    DECLARE @WithAudits BIT = (SELECT WithAudits
                               FROM dbo.Tables
                               WHERE Id = @Id);
    IF @WithAudits = 1
        EXEC dbo.DropTableAudit @Id;
    IF dbo.TableExists(@SchemaId, @Id) = 1
        BEGIN
            DELETE
            FROM dbo.Tables
            WHERE Id = @Id;
        END
    COMMIT;
END
GO
