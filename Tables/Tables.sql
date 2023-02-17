USE DataMatrix
GO

IF NOT EXISTS(SELECT *
              FROM sys.tables
              WHERE name = 'Tables')
    BEGIN
        CREATE TABLE dbo.Tables
        (
            Id         NVARCHAR(128)               NOT NULL
                CONSTRAINT Tables_pk
                    PRIMARY KEY NONCLUSTERED,
            SchemaId   NVARCHAR(128)               NOT NULL
                CONSTRAINT Tables_Schemas_Id_fk
                    REFERENCES dbo.Schemas
                    ON DELETE CASCADE,
            Name       VARCHAR(256)                NOT NULL,
            WithAudits BIT       DEFAULT 1         NOT NULL,
            AlterDate  DATETIME2 DEFAULT GETDATE() NOT NULL
        );

        CREATE UNIQUE INDEX Tables_Id_uindex
            ON dbo.Tables (Id);

        CREATE UNIQUE INDEX Tables_SchemaId_Name_uindex
            ON dbo.Tables (SchemaId, Name);

    END
GO

CREATE OR ALTER PROCEDURE dbo.InitializeTable(@SchemaId NVARCHAR(128), @Name VARCHAR(256), @WithAudits BIT,
                                              @Id NVARCHAR(128) OUTPUT)
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.CreateTable @SchemaId, @Name;
    EXEC dbo.InsertTable @SchemaId, @Name, @WithAudits, @Id OUTPUT;

    -- add the Id col to the Columns table
    DECLARE @colId NVARCHAR(128), @DataTypeId NVARCHAR(128) = dbo.GetDataTypeId('int');
    EXEC dbo.InsertTableColumn @Id, @DataTypeId, 'Id', NULL, NULL, 1, 1, 0, 0, 0, @colId OUTPUT

    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.ModifyTable(@Id NVARCHAR(128), @SchemaId NVARCHAR(128), @Name VARCHAR(256),
                                          @WithAudits BIT)
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.RenameTable @Id, @Name;
    EXEC dbo.UpdateTable @Id, @SchemaId, @Name, @WithAudits;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveTable(@Id NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION ;
    EXEC dbo.DropTable @Id;
    EXEC dbo.DeleteTable @Id;
    COMMIT;
END
GO
