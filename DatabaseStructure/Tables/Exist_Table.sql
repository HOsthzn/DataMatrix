-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Exist_Table]( @Schema VARCHAR(256), @Table VARCHAR(256) )
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT

    SET @result = IIF(EXISTS( SELECT 1
                                  FROM INFORMATION_SCHEMA.TABLES
                                  WHERE TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table ), 1, 0);

    RETURN @result
END
GO