-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Drop_ForeignKey]( @Schema         VARCHAR(256), @Table VARCHAR(256),
                                                       @ConstraintName NVARCHAR(256) )
--with encryption
AS
BEGIN

    DECLARE @TName NVARCHAR(256) = dbo.Concat_Schema_Table(@Schema, @Table);
    DECLARE @Dyno NVARCHAR(MAX) = 'ALTER TABLE ' + @TName + ' DROP CONSTRAINT ' + QUOTENAME(@ConstraintName) + ';';

    EXEC dbo.RunDynoCode @Dyno;
END
GO