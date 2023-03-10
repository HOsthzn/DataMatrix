USE DataMatrix
GO

-- Procedure to check if a table column exists
CREATE OR ALTER FUNCTION dbo.TableColumnExists(@TableId NVARCHAR(128), @ColumnName NVARCHAR(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM dbo.TableColumns
              WHERE TableId = @TableId
                  AND Name = @ColumnName
                 OR Id = @ColumnName)
        BEGIN
            RETURN 1
        END
    RETURN 0
END
GO

CREATE OR ALTER FUNCTION dbo.GetColumnOrdinal(@TableId NVARCHAR(128), @ColumnName NVARCHAR(128))
    RETURNS INT
AS
BEGIN
    DECLARE @SchemaName NVARCHAR(256), @Ordinal INT

    SELECT @SchemaName = S.Name
    FROM dbo.Tables AS T
             INNER JOIN dbo.Schemas AS S ON S.Id = T.SchemaId
    WHERE T.Id = @TableId

    SELECT @Ordinal = column_id
    FROM sys.columns
    WHERE object_id =
          OBJECT_ID(QUOTENAME(@SchemaName) + '.' + QUOTENAME((SELECT Name FROM dbo.Tables WHERE Id = @TableId)))
      AND name = @ColumnName

    IF @Ordinal IS NULL
        BEGIN
            SELECT @Ordinal = MAX(column_id) + 1
            FROM sys.columns
            WHERE object_id =
                  OBJECT_ID(QUOTENAME(@SchemaName) + '.' + QUOTENAME((SELECT Name FROM dbo.Tables WHERE Id = @TableId)))
        END

    RETURN @Ordinal
END
GO

-- Procedure to insert a table column
CREATE OR ALTER PROCEDURE dbo.InsertTableColumn(@TableId NVARCHAR(128), @DataTypeId NVARCHAR(128), @Name VARCHAR(256),
                                                @DefaultValue NVARCHAR(MAX), @Checks NVARCHAR(MAX), @NotNull BIT = 0,
                                                @IsPrimaryKey BIT = 0,
                                                @IsForeignKey BIT = 0, @IsForeignDisplayValue BIT = 0,
                                                @DisplayInGrid BIT = 0, @Id NVARCHAR(128) OUTPUT
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    IF dbo.TableColumnExists(@TableId, @Name) = 0
        BEGIN
            SET @Id = NEWID();
            INSERT INTO dbo.TableColumns ( Id, TableId, DataTypeId, Name, DefaultValue, Checks, NotNull, IsPrimaryKey
                                         , IsForeignKey, IsForeignDisplayValue, OrdinalPosition, DisplayInGrid
                                         , AlterDate)
            VALUES ( @Id, @TableId, @DataTypeId, @Name, @DefaultValue, @Checks, @NotNull, @IsPrimaryKey
                   , @IsForeignKey, @IsForeignDisplayValue, dbo.GetColumnOrdinal(@TableId, @Name), @DisplayInGrid
                   , @CurrentDate)
        END
END
GO

-- Procedure to update a table column
CREATE OR ALTER PROCEDURE dbo.UpdateTableColumn(
    @Id NVARCHAR(128),
    @TableId NVARCHAR(128),
    @DataTypeId NVARCHAR(128), @Checks NVARCHAR(MAX), @Name VARCHAR(256),
    @DefaultValue NVARCHAR(MAX), @NotNull BIT = 0, @IsPrimaryKey BIT = 0,
    @IsForeignKey BIT = 0, @IsForeignDisplayValue BIT = 0,
    @DisplayInGrid BIT = 0
)
AS
BEGIN
    DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
    IF dbo.TableColumnExists(@TableId, @Name) = 1
        BEGIN
            UPDATE dbo.TableColumns
            SET DataTypeId            = @DataTypeId
              , Name                  = @Name
              , DefaultValue          = @DefaultValue
              , Checks                = @Checks
              , NotNull               = @NotNull
              , IsPrimaryKey          = @IsPrimaryKey
              , IsForeignKey          = @IsForeignKey
              , IsForeignDisplayValue = @IsForeignDisplayValue
              , OrdinalPosition       = dbo.GetColumnOrdinal(@TableId, @Name)
              , DisplayInGrid         = @DisplayInGrid
              , AlterDate             = @CurrentDate
            WHERE Id = @Id
        END
END
GO

-- Procedure to delete a table column
CREATE OR ALTER PROCEDURE dbo.DeleteTableColumn(
    @Id NVARCHAR(128)
)
AS
BEGIN
    DECLARE @TableId NVARCHAR(128)
    SELECT @TableId = TableId FROM dbo.TableColumns WHERE Id = @Id

    IF dbo.TableColumnExists(@TableId, @Id) = 1
        BEGIN
            DELETE
            FROM dbo.TableColumns
            WHERE Id = @Id;
        END
END
GO
