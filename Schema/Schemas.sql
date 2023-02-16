USE DataMatrix
GO

IF NOT EXISTS(SELECT *
              FROM sys.tables
              WHERE name = 'Schemas')
    BEGIN
        CREATE TABLE dbo.Schemas
        (
            Id        NVARCHAR(128)               NOT NULL
                CONSTRAINT Schemas_pk
                    PRIMARY KEY,
            Name      VARCHAR(256)                NOT NULL,
            AlterDate DATETIME2 DEFAULT GETDATE() NOT NULL
        );

        CREATE UNIQUE INDEX Schemas_Name_uindex
            ON dbo.Schemas (Name);
    END
GO

CREATE OR ALTER PROCEDURE dbo.InitializeSchema(@Name VARCHAR(256), @Id NVARCHAR(128) OUTPUT)
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.CreateSchema @Name;
    EXEC dbo.InsertSchema @Name, @Id OUTPUT;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.ModifySchema(@Id NVARCHAR(128), @NewName VARCHAR(256))
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.RenameSchema @Id, @NewName;
    EXEC dbo.UpdateSchema @Id, @NewName;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveSchema(@Id NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.DropSchema @Id;
    EXEC dbo.DeleteSchema @Id;
    COMMIT;
END
GO
