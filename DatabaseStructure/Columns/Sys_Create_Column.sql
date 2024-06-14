-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Create_Column]( @Schema   VARCHAR(256), @Table VARCHAR(256), @Column VARCHAR(256),
                                                     @DataType VARCHAR(256), @NotNull BIT )
--with encryption
AS
BEGIN
    DECLARE @TName NVARCHAR(256) = dbo.Concat_Schema_Table(@Schema, @Table), @Dyno NVARCHAR(MAX);

    SELECT @Dyno = IIF(@NotNull = 1,
                       CONCAT('ALTER TABLE ', @TName, ' ADD ', @Column, ' ', @DataType, ' NOT NUll;'),
                       CONCAT('ALTER TABLE ', @TName, ' ADD ', @Column, ' ', @DataType, ';'));

    EXEC dbo.RunDynoCode @Dyno;
END
GO