-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Create_Table]( @Schema VARCHAR(256), @Table VARCHAR(256) )
--with encryption
AS
BEGIN
    DECLARE @TName NVARCHAR(256) = dbo.Concat_Schema_Table(@Schema, @Table);
    DECLARE @Dyno NVARCHAR(MAX) = CONCAT('CREATE TABLE ', @TName,
                                         '(Id int identity constraint ', @Table, '_pk primary key);');

    EXEC dbo.RunDynoCode @Dyno;
END
GO