USE DataMatrix
GO

IF NOT EXISTS(SELECT *
              FROM sys.tables
              WHERE name = 'TableColumns')
    BEGIN
        CREATE TABLE dbo.TableColumns
        (
            Id                    NVARCHAR(128)               NOT NULL
                CONSTRAINT TableColumns_pk
                    PRIMARY KEY NONCLUSTERED,
            TableId               NVARCHAR(128)               NOT NULL
                CONSTRAINT TableColumns_Tables_Id_fk
                    REFERENCES dbo.Tables
                    ON DELETE CASCADE,
            DataTypeId            NVARCHAR(128)               NOT NULL
                CONSTRAINT TableColumns_DataTypes_Id_fk
                    REFERENCES dbo.DataTypes
                    ON DELETE CASCADE,
            Name                  VARCHAR(256)                NOT NULL,
            DefaultValue          NVARCHAR(MAX),
            [Checks]              NVARCHAR(MAX) ,
            NotNull               BIT       DEFAULT 0         NOT NULL,
            IsPrimaryKey          BIT       DEFAULT 0         NOT NULL,
            IsForeignKey          BIT       DEFAULT 0         NOT NULL,
            IsForeignDisplayValue BIT       DEFAULT 0         NOT NULL,
            OrdinalPosition       INT                         NOT NULL,
            DisplayInGrid         BIT       DEFAULT 0         NOT NULL,
            AlterDate             DATETIME2 DEFAULT GETDATE() NOT NULL
        );

        CREATE UNIQUE INDEX TableColumns_Id_uindex
            ON dbo.TableColumns (Id);

        CREATE UNIQUE INDEX TableColumns_TableId_Name_uindex
            ON dbo.TableColumns (TableId, Name);
    END
GO

CREATE OR ALTER PROCEDURE dbo.InitializeTableColumn(@TableId NVARCHAR(128), @Name VARCHAR(256),
                                                    @DataTypeId NVARCHAR(128),
                                                    @Default NVARCHAR(MAX), @Checks nvarchar(MAX), @NotNull BIT, @IsPrimaryKey BIT,
                                                    @IsForeignKey BIT, @IsForeignDisplayValue BIT,
                                                    @DisplayInGrid BIT, @Id NVARCHAR(128) OUTPUT)
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.CreateColumn @TableId, @Name, @DataTypeId, @Default, @Checks, @NotNull;
    EXEC dbo.InsertTableColumn @TableId, @DataTypeId, @Name, @Default, @Checks, @NotNull, @IsPrimaryKey, @IsForeignKey,
         @IsForeignDisplayValue, @DisplayInGrid, @Id OUTPUT;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.ModifyTableColumn(@Id NVARCHAR(128), @TableId NVARCHAR(128),
                                                @Name VARCHAR(256), @Default NVARCHAR(MAX),
                                                @DataTypeId NVARCHAR(128), @NotNull BIT,
                                                @IsPrimaryKey BIT, @IsForeignKey BIT,
                                                @IsForeignDisplayValue BIT, @DisplayInGrid BIT)
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.AlterColumn @Id, @TableId, @Name, @Default, @DataTypeId, @NotNull;
    EXEC dbo.UpdateTableColumn @Id, @TableId, @DataTypeId, @Name, @Default, @NotNull, @IsPrimaryKey,
         @IsForeignKey, @IsForeignDisplayValue, @DisplayInGrid;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE dbo.RemoveTableColumn(@Id NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.DropColumn @Id;
    EXEC dbo.DeleteTableColumn @Id;
    COMMIT;
END
GO