create table dbo.TableForeignKeyRelation
(
    Id              nvarchar(128) not null
        constraint TableForeignKeyRelation_pk
            primary key nonclustered,
    Name            varchar(256)  not null,
    ForeignColumnId nvarchar(128) not null
        constraint TableForeignKeyRelation_ForeignTableColumns_Id_fk
            references dbo.TableColumns,
    PrimaryColumnId nvarchar(128) not null
        constraint TableForeignKeyRelation_PrimaryTableColumns_Id_fk
            references dbo.TableColumns
)
go

create unique index TableForeignKeyRelation_Id_uindex
    on dbo.TableForeignKeyRelation (Id)
go

create unique index TableForeignKeyRelation_ForeignColumnId_PrimaryColumnId_uindex
    on dbo.TableForeignKeyRelation (ForeignColumnId, PrimaryColumnId)
go