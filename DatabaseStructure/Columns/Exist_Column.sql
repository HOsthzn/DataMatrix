-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Exist_Column]( @Schema VARCHAR(256), @Table VARCHAR(256), @Column VARCHAR(256) )
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT

    SELECT @result = IIF(EXISTS ( SELECT 1
                                      FROM INFORMATION_SCHEMA.COLUMNS
                                      WHERE TABLE_SCHEMA = @Schema AND TABLE_NAME = @Table AND COLUMN_NAME = @Column ),
                         1, 0);

    RETURN @result
END
GO