CREATE OR ALTER FUNCTION dbo.GetSQLDataType(@id NVARCHAR(128))
    RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE @result VARCHAR(256), @Type VARCHAR(256), @Size VARCHAR(256)

    SELECT @Type = Type, @Size = Size
    FROM dbo.DataTypes
    WHERE Id = @Id
       OR LOWER(Code) = LOWER(@id)

    IF LEN(@Size) > 0 OR @Size IS NOT NULL
        BEGIN
            SET @result = @Type + '(' + @Size + ')'
        END
    ELSE
        BEGIN
            SET @result = @Type
        END

    RETURN @result
END