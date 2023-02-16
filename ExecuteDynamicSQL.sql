CREATE OR ALTER PROCEDURE [dbo].[ExecuteDynamicSQL](
    @sql NVARCHAR(MAX)
) AS
BEGIN
    BEGIN TRY
        --if @sql does not end with ; add it
        IF SUBSTRING(@sql, LEN(@sql), 1) <> ';'
            SET @sql = @sql + ';';
        PRINT @SQL;
        EXEC (@sql);
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
