create table dbo.TableColumns
(
    Id                    nvarchar(128) not null
        constraint TableColumns_pk
            primary key nonclustered,
    TableId               nvarchar(128) not null
        constraint TableColumns_Tables_Id_fk
            references dbo.Tables
            on delete cascade,
    DataTypeId            nvarchar(128) not null
        constraint TableColumns_DataTypes_Id_fk
            references dbo.DataTypes
            on delete cascade,
    Name                  varchar(256)  not null,
    DefaultValue          nvarchar(max),
    NotNull               bit default 0 not null,
    IsPrimaryKey          bit default 0 not null,
    IsForeignKey          bit default 0 not null,
    IsForeignDisplayValue bit default 0 not null,
    OrdinalPosition       int           not null,
    DisplayInGrid         bit default 0 not null
)
go

create unique index TableColumns_Id_uindex
    on dbo.TableColumns (Id)
go

create unique index TableColumns_TableId_Name_uindex
    on dbo.TableColumns (TableId, Name)
go

