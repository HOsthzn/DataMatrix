create table dbo.DataTypes
(
    Id             nvarchar(128) not null
        constraint PK_DataTypes
            primary key,
    Name           varchar(128)  not null,
    Code           varchar(10)   not null,
    Type           varchar(256)  not null,
    Description    varchar(max),
    Size           varchar(256),
    DateTimeFormat varchar(256),
    MaxValue       decimal(18, 6),
    MinValue       decimal(18, 6)
)
go

create unique index DataTypes_Id_uindex
    on dbo.DataTypes (Id)
go

create unique index DataTypes_Code_uindex
    on dbo.DataTypes (Code)
go

create unique index DataTypes_Name_uindex
    on dbo.DataTypes (Name)
go

INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'BIT', N'BIT', N'BIT', N'DEFAULT BIT TYPE', null, null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'VARCHAR', N'VAR', N'VARCHAR', N'DEFAULT string VALUE', N'256', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'HASH', N'HASH', N'NVARCHAR', N'DEFAULT HASH VALUE', N'MAX', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'INTEGER', N'INT', N'INT', N'DEFAULT INT TYPE', null, null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'DECIMAL', N'DEC', N'DECIMAL', N'DEFAULT DECIMAL TYPE', N'18,6', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'Phone Number', N'PNUM', N'NVARCHAR', N'DEFAULT phone number VALUE', N'MAX', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'DATETIME', N'DT', N'DATETIME', N'DEFAULT DATETIME TYPE', null, N'DD-MM-YYYY HH:MM', null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'DESCRIPTION', N'DESC', N'VARCHAR', N'DEFAULT DESCRIPTION VALUE', N'MAX', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'Email', N'EMAIL', N'NVARCHAR', N'DEFAULT email VALUE', N'256', null, null, null);
INSERT INTO DataTypes (Id, Name, Code, Type, Description, Size, DateTimeFormat, MaxValue, MinValue) VALUES (newid(), N'PRIMARY KEY/FOREIGN KEY', N'PK', N'NVARCHAR', N'DEFAULT PRIMARY KEY TYPE', N'128', null, null, null);
