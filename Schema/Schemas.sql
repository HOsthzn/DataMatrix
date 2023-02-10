create table dbo.Schemas
(
    Id   nvarchar(128) not null
        constraint Schemas_pk
            primary key,
    Name varchar(256)  not null,
    AlterDate Datetime2 default getdate() not null
)
go

create unique index Schemas_Name_uindex
    on dbo.Schemas (Name)
go