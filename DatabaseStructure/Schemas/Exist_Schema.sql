-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Exist_Schema]( @Schema VARCHAR(256) )
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT

    SELECT @result = IIF(EXISTS ( SELECT 1
                                      FROM INFORMATION_SCHEMA.SCHEMATA
                                      WHERE SCHEMA_NAME = @Schema ), 1, 0);

    RETURN @result
END
GO