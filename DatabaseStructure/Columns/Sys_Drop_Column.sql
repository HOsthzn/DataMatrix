-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Drop_Column]( @Schema VARCHAR(256), @Table VARCHAR(256), @Column VARCHAR(256) )
--with encryption
AS
BEGIN
    DECLARE @TName AS NVARCHAR(256) = dbo.Concat_Schema_Table(@Schema, @Table);
    DECLARE @Dyno NVARCHAR(MAX) = CONCAT('ALTER TABLE ', @TName, ' DROP COLUMN ', @Column, ';');

    EXEC dbo.RunDynoCode @Dyno;
END
GO