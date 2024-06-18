-- =============================================
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Create_Schema]( @Schema VARCHAR(256) )
--with encryption
AS
BEGIN
    DECLARE @Dyno NVARCHAR(MAX) = CONCAT('CREATE SCHEMA ', @Schema, ';');
    EXEC dbo.RunDynoCode @Dyno;
END
GO