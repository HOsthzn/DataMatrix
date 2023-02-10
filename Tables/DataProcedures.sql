-- Procedure to insert a table
CREATE PROCEDURE dbo.InsertTable(
    @SchemaId nvarchar(128),
    @Name varchar(256),
    @WithAudits bit = 1
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    DECLARE @Id nvarchar(128) = NEWID();

    INSERT INTO dbo.Tables (Id, SchemaId, Name, WithAudits, AlterDate)
    VALUES (@Id, @SchemaId, @Name, @WithAudits, @CurrentDate);
END
go

-- Procedure to update a table
CREATE PROCEDURE dbo.UpdateTable(
    @Id nvarchar(128),
    @SchemaId nvarchar(128),
    @Name varchar(256),
    @WithAudits bit
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();

    UPDATE dbo.Tables
    SET Name       = @Name
      , SchemaId   = @SchemaId
      , WithAudits = @WithAudits
      , AlterDate  = @CurrentDate
    WHERE Id = @Id;
END
go

-- Procedure to delete a table
CREATE PROCEDURE dbo.DeleteTable(
    @Id nvarchar(128)
)
AS
BEGIN
    DELETE
    FROM dbo.Tables
    WHERE Id = @Id ;
END
go
