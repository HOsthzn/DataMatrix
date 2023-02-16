DECLARE @SchemaName VARCHAR(256),@TableFromName VARCHAR(256), @TableToName VARCHAR(256),@SchemaId NVARCHAR(128), @TableFromId NVARCHAR(128), @TableToId NVARCHAR(128);

DECLARE @DataTypeId NVARCHAR(128), @ColId NVARCHAR(128);

SET @SchemaName = 'TestSchema'

EXEC dbo.InitializeSchema @SchemaName, @SchemaId OUTPUT;

SET @TableToName = 'foo'
EXEC dbo.InitializeTable @SchemaId, @TableToName, 0, @TableToId OUTPUT

SET @DataTypeId = dbo.GetDataTypeId('var');
EXEC dbo.InitializeTableColumn @TableToId, 'Name', @DataTypeId, NULL, 1, 0, 0, 1, 1, @ColId OUTPUT;

SET @TableFromName = 'bar'
EXEC dbo.InitializeTable @SchemaId, @TableFromName, 0, @TableFromId OUTPUT

DECLARE @ToColumnId NVARCHAR(128), @FromColumnId NVARCHAR(128), @FKId NVARCHAR(128)

SET @DataTypeId = dbo.GetDataTypeId('int');
EXEC dbo.InitializeTableColumn @TableFromId, 'fooId', @DataTypeId, NULL, 1, 0, 1, 0, 1, @FromColumnId OUTPUT;

SET @DataTypeId = dbo.GetDataTypeId('var');
EXEC dbo.InitializeTableColumn @TableFromId, 'Name', @DataTypeId, NULL, 1, 0, 0, 1, 1, @ColId OUTPUT;

SELECT @ToColumnId = Id
FROM TableColumns
WHERE TableId = @TableToId
  AND Name = 'Id'

EXEC InitializeTableForeignKeyRelation @FromColumnId, @ToColumnId, @FKId OUTPUT;

EXEC dbo.RemoveTableForeignKeyRelation @FKId;

EXEC dbo.RemoveTable @TableToId;
EXEC dbo.RemoveTable @TableFromId;

EXEC dbo.RemoveSchema @SchemaId;

-- Results
/*CREATE SCHEMA [TestSchema];
CREATE TABLE [TestSchema].[foo] (Id INT NOT NULL CONSTRAINT TestSchema_foo_pk PRIMARY KEY);
ALTER TABLE [TestSchema].[foo] ADD [Name] VARCHAR(256) NOT NULL;
CREATE TABLE [TestSchema].[bar] (Id INT NOT NULL CONSTRAINT TestSchema_bar_pk PRIMARY KEY);
ALTER TABLE [TestSchema].[bar] ADD [fooId] INT NOT NULL;
ALTER TABLE [TestSchema].[bar] ADD [Name] VARCHAR(256) NOT NULL;
ALTER TABLE TestSchema.bar ADD CONSTRAINT bar_fooId_foo_Id_fk FOREIGN KEY (fooId) REFERENCES TestSchema.foo (Id);
ALTER TABLE TestSchema.bar DROP CONSTRAINT bar_fooId_foo_Id_fk;
DROP TABLE IF EXISTS [TestSchema].[foo];
DROP TABLE IF EXISTS [TestSchema].[bar];
DROP SCHEMA [TestSchema];
[2023-02-16 14:31:12] 13 rows affected in 117 ms*/