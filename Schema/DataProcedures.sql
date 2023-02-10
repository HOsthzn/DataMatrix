CREATE PROCEDURE dbo.InsertSchema
(
    @Name varchar(256)
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();

    INSERT INTO dbo.Schemas (Id, Name, AlterDate)
    VALUES (NEWID(), @Name, @CurrentDate)
END
GO

CREATE PROCEDURE dbo.UpdateSchema
(
    @Id nvarchar(128),
    @Name varchar(256)
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();

    UPDATE dbo.Schemas
    SET Name = @Name,
        AlterDate = @CurrentDate
    WHERE Id = @Id
END
GO

CREATE PROCEDURE dbo.DeleteSchema
(
    @Id nvarchar(128)
)
AS
BEGIN
    DELETE FROM dbo.Schemas
    WHERE Id = @Id
END
GO