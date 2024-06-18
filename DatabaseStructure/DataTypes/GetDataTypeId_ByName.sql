-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/02/22
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[GetDataTypeId_ByName]( @Name NVARCHAR(256) )
    RETURNS NVARCHAR(450)
AS
BEGIN
    DECLARE @result NVARCHAR(450)

    SELECT @result = Id
        FROM dbo.DataTypes
        WHERE Name = @Name OR UPPER(Code) = UPPER(@Name)

    RETURN @result
END
GO