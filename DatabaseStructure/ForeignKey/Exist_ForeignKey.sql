-- =============================================
-- Copyright: © 2023 Polysphere (Pty) Ltd. All rights reserved.
-- Author: Hendrik Oosthuizen Jnr
-- Create date: 2024/05/24
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[Exist_ForeignKey]( @Schema VARCHAR(256), @Table VARCHAR(256), @ForeignKey VARCHAR(256) )
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT

    SET @result = IIF(EXISTS( SELECT 1
                                  FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS RC
                                      JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE    KCU
                                           ON KCU.CONSTRAINT_CATALOG = RC.CONSTRAINT_CATALOG
                                               AND KCU.CONSTRAINT_SCHEMA = RC.CONSTRAINT_SCHEMA
                                               AND KCU.CONSTRAINT_NAME = RC.CONSTRAINT_NAME
                                  WHERE KCU.TABLE_SCHEMA = @Schema
                                    AND KCU.TABLE_NAME = @Table
                                    AND KCU.CONSTRAINT_NAME = @ForeignKey ),
                      1, 0)

    RETURN @result
END
GO