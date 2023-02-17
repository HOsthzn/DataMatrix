USE DataMatrix
GO

CREATE OR ALTER PROCEDURE [dbo].[InitializeSchemaIntegration](@SchemaId NVARCHAR(128))
AS
BEGIN
    BEGIN TRANSACTION;
    EXEC dbo.CreateSchemaIntegrationTable @SchemaId;
    EXEC dbo.CreateSchemaIntegrationTableColumns @SchemaId;
    EXEC dbo.CreateSchemaIntegrationColumnMappings @SchemaId;
    COMMIT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaIntegrationTable](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'IntegrationConfiguration', 0, @TableId OUTPUT;

    DECLARE @var256 NVARCHAR(128)
    SET @var256 = dbo.GetDataTypeId('var');

    EXEC dbo.InitializeTableColumn @TableId, 'Server', @var256, NULL, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Database', @var256, NULL, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Schema', @var256, NULL, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'TableOrView', @var256, NULL, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaIntegrationTableColumns](@SchemaId NVARCHAR(128))
AS
BEGIN

    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128), @fromColId NVARCHAR(128), @toColId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'IntegrationColumns', 0, @TableId OUTPUT;

    DECLARE @var256 NVARCHAR(128), @pk NVARCHAR(128), @bit NVARCHAR(128), @int NVARCHAR(128);

    SET @var256 = dbo.GetDataTypeId('var');
    SET @pk = dbo.GetDataTypeId('pk');
    SET @bit = dbo.GetDataTypeId('bit');
    SET @int = dbo.GetDataTypeId('int');

    EXEC dbo.InitializeTableColumn @TableId, 'IntegrationConfigurationId', @int, NULL, NULL, 1, 0, 0, 0, 1,
         @fromColId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'Name', @var256, NULL, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'onFilter', @bit, 0, NULL, 1, 0, 0, 0, 1, @ColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'onFilterOperator', @var256, 0, '<,>,<>,=,>=,<=,not', 1, 0, 0, 0, 1,
         @ColumnId OUTPUT;

    SELECT @toColId = TC.Id
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
    WHERE TC.Name = 'Id'
      AND T.Name = 'IntegrationConfiguration'
      AND T.SchemaId = @SchemaId;

    EXEC dbo.InitializeTableForeignKeyRelation @fromColId, @toColId, @ColumnId OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE [dbo].[CreateSchemaIntegrationColumnMappings](@SchemaId NVARCHAR(128))
AS
BEGIN
    DECLARE @TableId NVARCHAR(128), @ColumnId NVARCHAR(128);
    EXEC dbo.InitializeTable @SchemaId, 'IntegrationColumnMapping', 0, @TableId OUTPUT;

    DECLARE @Pk NVARCHAR(128), @int NVARCHAR(128), @IntegrationColumnId NVARCHAR(128), @TableColumnId NVARCHAR(128), @toColId NVARCHAR(128);

    SET @Pk = dbo.GetDataTypeId('pk');
    SET @int = dbo.GetDataTypeId('int');

    EXEC dbo.InitializeTableColumn @TableId, 'IntegrationColumnId', @int, NULL, NULL, 1, 0, 1, 0, 1,
         @IntegrationColumnId OUTPUT;
    EXEC dbo.InitializeTableColumn @TableId, 'TableColumnId', @Pk, NULL, NULL, 1, 0, 1, 0, 1, @TableColumnId OUTPUT;

    SELECT @toColId = TC.Id
    FROM dbo.TableColumns AS TC
             INNER JOIN Tables AS T ON T.Id = TC.TableId
    WHERE TC.Name = 'Id'
      AND T.Name = 'IntegrationColumns'
      AND T.SchemaId = @SchemaId;

    IF @toColId IS NULL
        RAISERROR ('Table IntegrationColumns does not exist', 16, 1);
    ELSE
        EXEC dbo.InitializeTableForeignKeyRelation @IntegrationColumnId, @toColId, @ColumnId OUTPUT;

    DECLARE @SchemaName NVARCHAR(128) = (SELECT Name FROM Schemas WHERE Id = @SchemaId);

    DECLARE @sql NVARCHAR(MAX) = N'ALTER TABLE ' + @SchemaName + '.IntegrationColumnMapping
            ADD CONSTRAINT ' + @SchemaName + '_IntegrationColumnMapping_TableColumns_Id_fk
            FOREIGN KEY (TableColumnId) REFERENCES dbo.TableColumns(Id)';

    EXEC dbo.ExecuteDynamicSQL @sql;
END