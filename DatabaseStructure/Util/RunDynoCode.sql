-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/02/22
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[RunDynoCode]( @Dyno NVARCHAR(MAX) )
--with encryption
AS
BEGIN
    --WITH EXECUTE AS OWNER;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            -- Validate input
            IF (NULLIF(@Dyno, '') IS NULL)
                THROW 51000, 'Empty command is not allowed', 1;

            PRINT CONCAT('Running Dyno Code: ', @Dyno)

            EXEC (@Dyno)
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        DECLARE
            @message NVARCHAR(MAX)
            ,@xstate INT;

        SELECT @message = 'ERROR in Stored Procedure RunDynoCode: ' + ERROR_MESSAGE()
             , @xstate = XACT_STATE();

        IF @xstate > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
        THROW;
    END CATCH
END
GO