create table dbo.Tables
(
    Id         nvarchar(128) not null
        constraint Tables_pk
            primary key nonclustered,
    SchemaId   nvarchar(128) not null
        constraint Tables_Schemas_Id_fk
            references dbo.Schemas
            on delete cascade,
    Name       varchar(256)  not null,
    WithAudits bit default 1 not null
)
go

create unique index Tables_Id_uindex
    on dbo.Tables (Id)
go

create unique index Tables_SchemaId_Name_uindex
    on dbo.Tables (SchemaId, Name)
go

