-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Delete_Table]( @Schema VARCHAR(256), @Table VARCHAR(256) )
--with encryption
AS
BEGIN
    --WITH EXECUTE AS OWNER;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @Exist BIT = dbo.Exist_Table(@Schema, @Table);

            IF (@Exist = 1)
                EXEC dbo.Sys_Drop_Table @Schema, @Table;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        DECLARE
            @message NVARCHAR(MAX)
            ,@xstate INT;

        SELECT @message = 'ERROR in Stored Procedure Delete_Table: ' + ERROR_MESSAGE()
             , @xstate = XACT_STATE();

        IF @xstate > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
        THROW;
    END CATCH
END
GO