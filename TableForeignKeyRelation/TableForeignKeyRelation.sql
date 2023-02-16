USE DataMatrix
GO

IF NOT EXISTS(SELECT *
              FROM sys.tables
              WHERE name = 'TableForeignKeyRelation')
    BEGIN

        CREATE TABLE dbo.TableForeignKeyRelation
        (
            Id              NVARCHAR(128)               NOT NULL
                CONSTRAINT TableForeignKeyRelation_pk
                    PRIMARY KEY NONCLUSTERED,
            Name            VARCHAR(256)                NOT NULL,
            ForeignColumnId NVARCHAR(128)               NOT NULL
                CONSTRAINT TableForeignKeyRelation_ForeignTableColumns_Id_fk
                    REFERENCES dbo.TableColumns,
            PrimaryColumnId NVARCHAR(128)               NOT NULL
                CONSTRAINT TableForeignKeyRelation_PrimaryTableColumns_Id_fk
                    REFERENCES dbo.TableColumns,
            AlterDate       DATETIME2 DEFAULT GETDATE() NOT NULL
        );

        CREATE UNIQUE INDEX TableForeignKeyRelation_Id_uindex
            ON dbo.TableForeignKeyRelation (Id);

        CREATE UNIQUE INDEX TableForeignKeyRelation_ForeignColumnId_PrimaryColumnId_uindex
            ON dbo.TableForeignKeyRelation (ForeignColumnId, PrimaryColumnId);

    END
GO

CREATE OR ALTER PROCEDURE dbo.InitializeTableForeignKeyRelation(@fromColumn NVARCHAR(128), @toColumn NVARCHAR(128),
                                                                @id NVARCHAR(128) OUTPUT)
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @Name VARCHAR(256) = dbo.GetForeignKeyRelationName(@FromColumn, @ToColumn);

    EXEC dbo.CreateForeignKeyRelation @Name, @FromColumn, @ToColumn;
    EXEC dbo.InsertTableForeignKeyRelation @Name, @FromColumn, @ToColumn, @Id OUTPUT;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.ModifyTableForeignKeyRelation(@Id NVARCHAR(128), @FromColumn NVARCHAR(128),
                                                            @ToColumn NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @Name VARCHAR(256) = dbo.GetForeignKeyRelationName(@FromColumn, @ToColumn);

    EXEC dbo.AlterForeignKeyRelation @Name, @FromColumn, @ToColumn;
    EXEC dbo.UpdateTableForeignKeyRelation @Id, @FromColumn, @ToColumn;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveTableForeignKeyRelation(@Id NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    DECLARE @FromColumn NVARCHAR(128), @ToColumn NVARCHAR(128);
    SELECT @FromColumn = ForeignColumnId, @ToColumn = PrimaryColumnId FROM dbo.TableForeignKeyRelation WHERE Id = @Id;
    DECLARE @Name VARCHAR(256) = dbo.GetForeignKeyRelationName(@FromColumn, @ToColumn);

    EXEC dbo.DropForeignKeyRelation @Name;
    EXEC dbo.DeleteTableForeignKeyRelation @Id;
    COMMIT;
END
GO