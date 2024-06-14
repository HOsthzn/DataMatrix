-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Delete_ForeignKey]( @Schema         VARCHAR(256), @Table VARCHAR(256),
                                                     @ConstraintName NVARCHAR(256) )
--with encryption
AS
BEGIN
    --WITH EXECUTE AS OWNER;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @Exist BIT = dbo.Exist_ForeignKey(@Schema, @Table, @ConstraintName);

            IF (@Exist = 1)
                EXEC dbo.Sys_Drop_ForeignKey @Schema, @Table, @ConstraintName;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        DECLARE
            @message NVARCHAR(MAX)
            ,@xstate INT;

        SELECT @message = 'ERROR in Stored Procedure Delete_ForeignKey: ' + ERROR_MESSAGE()
             , @xstate = XACT_STATE();

        IF @xstate > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
        THROW;
    END CATCH
END
GO