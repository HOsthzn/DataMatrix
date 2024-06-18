-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Create_ForeignKey](
    @SchemaSource VARCHAR(256), @TableSource VARCHAR(256), @ColumnSource VARCHAR(256),
    @SchemaTarget VARCHAR(256), @TableTarget VARCHAR(256), @ColumnTarget VARCHAR(256) )
--with encryption
AS
BEGIN
    --WITH EXECUTE AS OWNER;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @ConstraintName NVARCHAR(256) = dbo.Create_ConstraintName_ForeignKey(@SchemaSource, @TableSource,
                                                                                         @ColumnSource, @SchemaTarget,
                                                                                         @TableTarget, @ColumnTarget);

            DECLARE @Exist BIT = dbo.Exist_ForeignKey(@SchemaSource, @TableSource, @ConstraintName);

            IF (@Exist <> 1)
                EXEC dbo.Sys_Create_ForeignKey @SchemaSource, @TableSource, @ColumnSource, @SchemaTarget,
                     @TableTarget, @ColumnTarget, @ConstraintName;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        DECLARE
            @message NVARCHAR(MAX)
            ,@xstate INT;

        SELECT @message = 'ERROR in Stored Procedure Create_ForeignKey: ' + ERROR_MESSAGE()
             , @xstate = XACT_STATE();

        IF @xstate > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
        THROW;
    END CATCH
END
GO