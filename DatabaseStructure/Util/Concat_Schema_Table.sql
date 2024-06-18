-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Concat_Schema_Table]( @Schema VARCHAR(256), @Table VARCHAR(256) )
    RETURNS NVARCHAR(450)
AS
BEGIN
    DECLARE @result NVARCHAR(450)


    SET @result = CONCAT(QUOTENAME(@Schema), '.', QUOTENAME(@Table))

    RETURN @result
END
GO