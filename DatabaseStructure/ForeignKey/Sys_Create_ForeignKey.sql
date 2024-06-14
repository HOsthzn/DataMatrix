-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER PROCEDURE [dbo].[Sys_Create_ForeignKey](
    @SchemaSource   VARCHAR(256), @TableSource VARCHAR(256), @ColumnSource VARCHAR(256),
    @SchemaTarget   VARCHAR(256), @TableTarget VARCHAR(256), @ColumnTarget VARCHAR(256),
    @ConstraintName NVARCHAR(256)
)
--with encryption
AS
BEGIN
    DECLARE @SourceTableName NVARCHAR(450) = dbo.Concat_Schema_Table(@SchemaSource, @TableSource);
    DECLARE @TargetTableName NVARCHAR(450) = dbo.Concat_Schema_Table(@SchemaTarget, @TableTarget);

    DECLARE @Dyno NVARCHAR(MAX);
    SET @Dyno = 'ALTER TABLE ' + @SourceTableName + ' ADD CONSTRAINT '
        + QUOTENAME(@ConstraintName) + ' FOREIGN KEY (' + QUOTENAME(@ColumnSource)
        + ') REFERENCES ' + @TargetTableName + '(' + QUOTENAME(@ColumnTarget) + ');';

    -- Execute dynamic SQL
    EXEC dbo.RunDynoCode @Dyno;
END
GO