-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Drop_Schema]( @Schema VARCHAR(256) )
--with encryption
AS
BEGIN
    DECLARE @Dyno NVARCHAR(MAX) = CONCAT('DROP SCHEMA ', @Schema, ';');
    EXEC dbo.RunDynoCode @Dyno;
END
GO