CREATE OR ALTER PROCEDURE [dbo].[InitializeSchemaFileUpload](@SchemaId NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.CreateSchemaFilesTable @SchemaId;
    EXEC dbo.CreateSchemaFileTabs @SchemaId;
    EXEC dbo.CreateSchemaFileTabColumns @SchemaId;
    EXEC dbo.CreateSchemaFileTabColumnMappings @SchemaId;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaFilesTable](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'Files', 0, @TableId OUTPUT;

    DECLARE @var256 NVARCHAR(128),@varMax NVARCHAR(128),@DateTime NVARCHAR(128);

    SET @var256 = dbo.GetDataTypeId('var');
    SET @varMax = dbo.GetDataTypeId('desc');
    SET @DateTime = dbo.GetDataTypeId('Dt');

    EXEC dbo.InitializeTableColumn @TableId, 'Name', @var256, NULL, 1, 0, 0, 1, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Directory', @varMax, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'AlterDate', @DateTime, 'GETDATE()', 1, 0, 0, 0, 1, @ColumnId OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaFileTabs](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128), @fromColId NVARCHAR(128), @toColId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'FileTabs', 0, @TableId OUTPUT;

    DECLARE @var256 NVARCHAR(128),@DateTime NVARCHAR(128), @int NVARCHAR(128);

    SET @var256 = dbo.GetDataTypeId('var');
    SET @DateTime = dbo.GetDataTypeId('Dt');
    SET @int = dbo.GetDataTypeId('int');

    EXEC dbo.InitializeTableColumn @TableId, 'FileId', @int, NULL, 1, 0, 1, 0, 1, @fromColId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Name', @var256, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'AlterDate', @DateTime, 'GETDATE()', 1, 0, 0, 0, 1, @ColumnId OUTPUT;

    SELECT @toColId = TC.Id
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
    WHERE TC.Name = 'Id'
      AND T.Name = 'Files'
      AND T.SchemaId = @SchemaId;

    IF @toColId IS NULL
        RAISERROR ('Table Files does not exist', 16, 1);
    ELSE
        EXEC dbo.InitializeTableForeignKeyRelation @fromColId, @toColId, @ColumnId OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaFileTabColumns](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128), @fromColId NVARCHAR(128), @toColId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'FileTabColumns', 0, @TableId OUTPUT;

    DECLARE @var256 NVARCHAR(128),@DateTime NVARCHAR(128), @int NVARCHAR(128);

    SET @var256 = dbo.GetDataTypeId('var');
    SET @DateTime = dbo.GetDataTypeId('Dt');
    SET @int = dbo.GetDataTypeId('int');

    EXEC dbo.InitializeTableColumn @TableId, 'FileTabId', @int, NULL, 1, 0, 1, 0, 1, @fromColId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Name', @var256, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'OrdinalPosition', @int, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'AlterDate', @DateTime, 'GETDATE()', 1, 0, 0, 0, 1, @ColumnId OUTPUT;

    SELECT @toColId = TC.Id
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
    WHERE TC.Name = 'Id'
      AND T.Name = 'FileTabs'
      AND T.SchemaId = @SchemaId;

    IF @toColId IS NULL
        RAISERROR ('Table FileTabs does not exist', 16, 1);
    ELSE
        EXEC dbo.InitializeTableForeignKeyRelation @fromColId, @toColId, @ColumnId OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaFileTabColumnMappings](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'FileTabColumnMapping', 0, @TableId OUTPUT;

    DECLARE @Pk NVARCHAR(128), @int NVARCHAR(128), @FileTabColumnId NVARCHAR(128), @TableColumnId NVARCHAR(128), @toColId NVARCHAR(128);

    SET @Pk = dbo.GetDataTypeId('pk');
    SET @int = dbo.GetDataTypeId('int');

    EXEC dbo.InitializeTableColumn @TableId, 'FileTabColumnId', @int, NULL, 1, 0, 1, 0, 1, @FileTabColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'TableColumnId', @Pk, NULL, 1, 0, 1, 0, 1, @TableColumnId OUTPUT;

    SELECT @toColId = TC.Id
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
    WHERE TC.Name = 'Id'
      AND T.Name = 'FileTabColumns'
      AND T.SchemaId = @SchemaId;

    IF @toColId IS NULL
        RAISERROR ('Table FileTabColumns does not exist', 16, 1);
    ELSE
        EXEC dbo.InitializeTableForeignKeyRelation @FileTabColumnId, @toColId, @ColumnId OUTPUT;


    DECLARE @SchemaName NVARCHAR(128) = (SELECT Name FROM Schemas WHERE Id = @SchemaId);

    DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @SchemaName + '.FileTabColumnMapping
        ADD CONSTRAINT ' + @SchemaName + '_FileTabColumnMapping_TableColumns_Id_fk
            FOREIGN KEY (TableColumnId) REFERENCES dbo.TableColumns(Id)';

    EXEC dbo.ExecuteDynamicSQL @sql;
END