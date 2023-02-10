CREATE FUNCTION dbo.SchemaExists(@SchemaName varchar(256))
    RETURNS BIT
AS
BEGIN
    IF EXISTS(SELECT 1
              FROM sys.schemas
              WHERE name = @SchemaName)
        BEGIN
            RETURN 1
        END
    ELSE
        BEGIN
            RETURN 0
        END
END

CREATE PROCEDURE dbo.CreateSchema(
    @Name VARCHAR(256)
)
AS
BEGIN
    If dbo.SchemaExists(@Name) = 0
        begin

            DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
            DECLARE @Id UNIQUEIDENTIFIER = NEWID();

            begin try
                DECLARE @SQL NVARCHAR(MAX) = N'CREATE SCHEMA @SchemaName';
                EXEC sp_executesql @SQL, N'@SchemaName VARCHAR(256)', @Name;

                -- Also create an Audit schema
                DECLARE @SQL_Audit NVARCHAR(MAX) = N'CREATE SCHEMA @AuditSchemaName';
                EXEC sp_executesql @SQL_Audit, N'@AuditSchemaName VARCHAR(256)', @Name + '_Audit';

                exec dbo.InsertSchema @Name;
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
    CREATE PROCEDURE dbo.RenameSchema(
        @CurrentName VARCHAR(256),
        @NewName VARCHAR(256)
    )
    AS
    BEGIN
        If dbo.SchemaExists(@CurrentName) = 1
            begin
                DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
                DECLARE @Id UNIQUEIDENTIFIER;

                SELECT @Id = Id
                FROM dbo.Schemas
                WHERE Name = @CurrentName;

                begin try
                    DECLARE @SQL NVARCHAR(MAX) = N'ALTER SCHEMA @CurrentName TRANSFER @NewName';
                    EXEC sp_executesql @SQL, N'@CurrentName VARCHAR(256), @NewName VARCHAR(256)', @CurrentName,
                         @NewName;

                    -- Also update the Audit schema
                    DECLARE @SQL_Audit NVARCHAR(MAX) = N'ALTER SCHEMA @CurrentName_Audit TRANSFER @NewName_Audit';
                    EXEC sp_executesql @SQL_Audit, N'@CurrentName_Audit VARCHAR(512), @NewName_Audit VARCHAR(512)',
                         @CurrentName + '_Audit', @NewName + '_Audit';

                    exec dbo.UpdateSchema @Id, @NewName;
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
go


CREATE PROCEDURE dbo.DropSchema(@Name VARCHAR(256))
AS
BEGIN
    If dbo.SchemaExists(@Name) = 1
        begin
            DECLARE @CurrentDate DATETIME2 = SYSDATETIME();
            DECLARE @Id UNIQUEIDENTIFIER;

            SELECT @Id = Id
            FROM dbo.Schemas
            WHERE Name = @Name;

            begin try
                DECLARE @SQL NVARCHAR(MAX) = N'DROP SCHEMA [' + @Name + ']';
                EXEC sp_executesql @SQL;

                -- Also drop the Audit schema
                DECLARE @SQL_Audit NVARCHAR(MAX) = N'DROP SCHEMA [' + @Name + '_Audit]';
                EXEC sp_executesql @SQL_Audit;

                exec dbo.DeleteSchema @Id
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
GO
