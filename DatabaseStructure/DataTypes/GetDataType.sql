-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/02/22
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[GetDataType]( @DataTypeId NVARCHAR(450) )
    RETURNS NVARCHAR(256)
AS
BEGIN
    DECLARE @result NVARCHAR(256)

    DECLARE @Type NVARCHAR(256), @Size NVARCHAR(256)

    SELECT @Type = Type, @Size = Size
        FROM dbo.DataTypes
        WHERE Id = @DataTypeId

    IF (@Size IS NOT NULL)
        BEGIN
            SET @result = CONCAT(@Type, '(', @Size, ')')
        END
    ELSE
        BEGIN
            SET @result = @Type
        END

    RETURN @result
END
GO