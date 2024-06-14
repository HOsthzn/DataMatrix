-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Create_Column]( @Schema     VARCHAR(256), @Table VARCHAR(256), @Column VARCHAR(256),
                                                 @DataTypeId NVARCHAR(450), @NotNull BIT )
--with encryption
AS
BEGIN
    --WITH EXECUTE AS OWNER;
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @DataType VARCHAR(256) = dbo.GetDataType(@DataTypeId);
            DECLARE @Exist BIT =dbo.Exist_Column(@Schema, @Table, @Column);

            IF (@Exist <> 1)
                EXEC dbo.Sys_Create_Column @Schema, @Table, @Column, @DataType, @NotNull;
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        DECLARE
            @message NVARCHAR(MAX)
            ,@xstate INT;

        SELECT @message = 'ERROR in Stored Procedure Create_Column: ' + ERROR_MESSAGE()
             , @xstate = XACT_STATE();

        IF @xstate > 0
            BEGIN
                ROLLBACK TRANSACTION;
            END;
        THROW;
    END CATCH
END
GO