CREATE FUNCTION dbo.TableExists(@SchemaId nvarchar(128), @TableName varchar(256))
    RETURNS BIT
AS
BEGIN
    DECLARE @SchemaName varchar(256)

    SELECT @SchemaName = Name
    FROM dbo.Schemas
    WHERE Id = @SchemaId

    IF EXISTS(SELECT 1
              FROM sys.tables
              WHERE name = @TableName
                AND schema_name(schema_id) = @SchemaName)
        BEGIN
            RETURN 1
        END
    ELSE
        BEGIN
            RETURN 0
        END
END

CREATE PROCEDURE dbo.CreateTable(
    @SchemaId nvarchar(128),
    @Name varchar(256),
    @WithAudits bit = 1
)
AS
BEGIN
    if dbo.TableExists(@SchemaId, @Name) = 0
        begin
            DECLARE @SchemaName varchar(256);
            SELECT @SchemaName = Name FROM dbo.Schemas WHERE Id = @SchemaId;

            DECLARE @SQL nvarchar(MAX);
            SET @SQL = N'CREATE TABLE [' + @SchemaName + N'].[' + @Name +
                       N']([Id] int identity constraint ' + @SchemaName + '_' + @Name +
                       '_Id_pk primary key);';

            BEGIN TRY
                EXEC sp_executesql @SQL, N'@SchemaName nvarchar(256), @Name nvarchar(256)', @SchemaName, @Name;

                IF @WithAudits = 1
                    BEGIN
                        DECLARE @SQL_Audit nvarchar(MAX);
                        SET @SQL_Audit = N'CREATE TABLE [' + @SchemaName + N'_Audit].[' + @Name +
                                         N']([Id] int identity constraint ' + @SchemaName + '_' + @Name +
                                         '_Id_pk primary key, Action varchar(256), Date datetime2);';

                        EXEC sp_executesql @SQL_Audit, N'@SchemaName nvarchar(256), @Name nvarchar(256)', @SchemaName,
                             @Name;
                    END

                EXEC dbo.InsertTable @SchemaId, @Name, @WithAudits;
            END TRY
            BEGIN CATCH
                DECLARE @errorMessage NVARCHAR(4000);
                DECLARE @errorSeverity INT;
                DECLARE @errorState INT;

                SELECT @errorMessage = ERROR_MESSAGE()
                     , @errorSeverity = ERROR_SEVERITY()
                     , @errorState = ERROR_STATE();

                RAISERROR (@errorMessage, @errorSeverity, @errorState);
            END CATCH
        end
END
    CREATE PROCEDURE dbo.RenameTable(@SchemaId nvarchar(128), @CurrentName varchar(256), @NewName varchar(256))
    AS
    BEGIN
        IF dbo.TableExists(@SchemaId, @CurrentName) = 1
            BEGIN
                DECLARE @SchemaName varchar(256), @WithAudits bit;

                SELECT @SchemaName = Name
                FROM dbo.Schemas
                WHERE Id = @SchemaId;

                SELECT @WithAudits = WithAudits
                FROM dbo.Tables
                WHERE Name = @CurrentName
                  AND SchemaId = @SchemaId;

                DECLARE @SQL NVARCHAR(MAX);
                SET @SQL = N'EXEC sp_rename @objname = N''' + @SchemaName + N'.' + @CurrentName + ''', @newname = N''' +
                           @NewName + ''';';

                begin try
                    EXEC sp_executesql @SQL, N'@objname nvarchar(512), @newname nvarchar(512)',
                         @SchemaName + N'.' + @CurrentName, @NewName;

                    -- Also rename the Audit table if the WithAudits field is set to true
                    IF @WithAudits = 1
                        BEGIN
                            DECLARE @SQL_Audit NVARCHAR(MAX);
                            SET @SQL_Audit = N'EXEC sp_rename @objname = N''' + @SchemaName + '_Audit.' + @CurrentName +
                                             ''', @newname = N''' + @NewName + '_Audit'';';
                            EXEC sp_executesql @SQL_Audit, N'@objname nvarchar(512), @newname nvarchar(512)',
                                 @SchemaName + '_Audit.' + @CurrentName, @NewName + '_Audit';
                        END

                    EXEC dbo.UpdateTableName @CurrentName, @NewName;
                END TRY
                BEGIN CATCH
                    DECLARE @errorMessage NVARCHAR(4000);
                    DECLARE @errorSeverity INT;
                    DECLARE @errorState INT;

                    SELECT @errorMessage = ERROR_MESSAGE()
                         , @errorSeverity = ERROR_SEVERITY()
                         , @errorState = ERROR_STATE();

                    RAISERROR (@errorMessage, @errorSeverity, @errorState);
                END CATCH
            END
    END
GO

CREATE PROCEDURE dbo.DropTable(@SchemaId nvarchar(128), @Id nvarchar(128))
AS
BEGIN
    Declare @TableName varchar(256), @WithAudits bit;
    select @WithAudits = WithAudits, @TableName = Name from dbo.Tables where Id = @Id;
    if @TableName is not null
        BEGIN
            DECLARE @SchemaName varchar(256);
            SELECT @SchemaName = Name FROM dbo.Schemas WHERE Id = @SchemaId;

            DECLARE @SQL NVARCHAR(MAX) = N'DROP TABLE [' + @SchemaName + N'].[' + @TableName + N'];';

            begin try
                -- Drop the table
                EXEC sp_executesql @SQL, N'@SchemaName varchar(256), @TableName varchar(256)', @SchemaName, @TableName;

                -- Also drop the Audit table if the WithAudits field is set to true
                IF @WithAudits = 1
                    begin
                        DECLARE @SQL_Audit NVARCHAR(MAX) = N'DROP TABLE [' + @SchemaName + N'_Audit].[' + @TableName + N'];';
                        EXEC sp_executesql @SQL_Audit, N'@SchemaName varchar(256), @TableName varchar(256)',
                             @SchemaName,
                             @TableName;
                    end

                exec dbo.DeleteTable @Id;
            END TRY
            BEGIN CATCH
                DECLARE @errorMessage NVARCHAR(4000);
                DECLARE @errorSeverity INT;
                DECLARE @errorState INT;

                SELECT @errorMessage = ERROR_MESSAGE()
                     , @errorSeverity = ERROR_SEVERITY()
                     , @errorState = ERROR_STATE();

                RAISERROR (@errorMessage, @errorSeverity, @errorState);
            END CATCH
        END
END
GO
