CREATE TABLE DataTypes
(
    Id             NVARCHAR(450) NOT NULL
        CONSTRAINT PK_DataTypes
            PRIMARY KEY,
    Name           VARCHAR(128)  NOT NULL,
    Code           VARCHAR(10)   NOT NULL,
    Type           VARCHAR(256)  NOT NULL,
    Description    VARCHAR(MAX),
    Size           VARCHAR(256),
    DateTimeFormat VARCHAR(256),
    MaxValue       DECIMAL(18, 6),
    MinValue       DECIMAL(18, 6)
)
GO

CREATE UNIQUE INDEX DataTypes_Id_uindex
    ON DataTypes (Id)
GO

CREATE UNIQUE INDEX DataTypes_Code_uindex
    ON DataTypes (Code)
GO

CREATE UNIQUE INDEX DataTypes_Name_uindex
    ON DataTypes (Name)
GO

INSERT INTO DataMatrix.dbo.DataTypes ( Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue )
    VALUES ( NEWID(), N'BIT', N'BIT', N'BIT', N'DEFAULT BIT TYPE', NULL, NULL, NULL, NULL )
         , ( NEWID(), N'VARCHAR', N'VAR', N'VARCHAR', N'DEFAULT string VALUE', N'256', NULL, NULL, NULL )
         , ( NEWID(), N'HASH', N'HASH', N'NVARCHAR', N'DEFAULT HASH VALUE', N'MAX', NULL, NULL, NULL )
         , ( NEWID(), N'INTEGER', N'INT', N'INT', N'DEFAULT INT TYPE', NULL, NULL, NULL, NULL )
         , ( NEWID(), N'DECIMAL', N'DEC', N'DECIMAL', N'DEFAULT DECIMAL TYPE', N'18,6', NULL, NULL, NULL )
         , ( NEWID(), N'Phone Number', N'PNUM', N'NVARCHAR', N'DEFAULT phone number VALUE', N'MAX', NULL, NULL, NULL )
         , ( NEWID(), N'DATETIME', N'DT', N'DATETIME', N'DEFAULT DATETIME TYPE', NULL, N'DD-MM-YYYY HH:MM', NULL, NULL )
         , ( NEWID(), N'DESCRIPTION', N'DESC', N'VARCHAR', N'DEFAULT DESCRIPTION VALUE', N'MAX', NULL, NULL, NULL )
         , ( NEWID(), N'Email', N'EMAIL', N'NVARCHAR', N'DEFAULT email VALUE', N'256', NULL, NULL, NULL )
         , ( NEWID(), N'PRIMARY KEY/FOREIGN KEY', N'PK', N'INT', N'DEFAULT PRIMARY KEY TYPE', NULL, NULL, NULL, NULL );
