CREATE OR ALTER VIEW View_ForeignKeys AS
SELECT tc.CONSTRAINT_CATALOG AS DatabaseName
     , tc.TABLE_SCHEMA       AS SchemaName
     , tc.TABLE_NAME         AS TableName
     , tc.CONSTRAINT_NAME    AS ConstraintName
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tc
        INNER JOIN INFORMATION_SCHEMA.TABLES  AS t
                   ON tc.TABLE_NAME = t.TABLE_NAME
    WHERE (tc.TABLE_SCHEMA = 'dbo' OR (tc.TABLE_SCHEMA NOT LIKE 'sys%' AND tc.TABLE_SCHEMA NOT LIKE 'db_%'))
      AND t.TABLE_TYPE = 'BASE TABLE'
      AND (tc.CONSTRAINT_NAME NOT LIKE 'PK\_%' ESCAPE
           '\' AND tc.CONSTRAINT_NAME NOT LIKE '\_%pk' ESCAPE '\' AND tc.CONSTRAINT_NAME NOT LIKE '%\_pk' ESCAPE '\')
GO