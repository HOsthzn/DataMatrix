-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Create_ConstraintName_ForeignKey](
    @SchemaSource VARCHAR(256),
    @TableSource  VARCHAR(256),
    @ColumnSource VARCHAR(256),
    @SchemaTarget VARCHAR(256),
    @TableTarget  VARCHAR(256),
    @ColumnTarget VARCHAR(256)
)
    RETURNS NVARCHAR(450)
AS
BEGIN
    DECLARE @cleanSchemaSource VARCHAR(256) = REPLACE(REPLACE(@SchemaSource, ' ', '_'), '.', '_');
    DECLARE @cleanTableSource VARCHAR(256) = REPLACE(REPLACE(@TableSource, ' ', '_'), '.', '_');
    DECLARE @cleanColumnSource VARCHAR(256) = REPLACE(REPLACE(@ColumnSource, ' ', '_'), '.', '_');
    DECLARE @cleanSchemaTarget VARCHAR(256) = REPLACE(REPLACE(@SchemaTarget, ' ', '_'), '.', '_');
    DECLARE @cleanTableTarget VARCHAR(256) = REPLACE(REPLACE(@TableTarget, ' ', '_'), '.', '_');
    DECLARE @cleanColumnTarget VARCHAR(256) = REPLACE(REPLACE(@ColumnTarget, ' ', '_'), '.', '_');

    DECLARE @result NVARCHAR(450) = CONCAT('FK_', @cleanSchemaSource, '_', @cleanTableSource, '_', @cleanColumnSource,
                                           '_', @cleanSchemaTarget, '_', @cleanTableTarget, '_', @cleanColumnTarget);

    RETURN @result;
END
GO