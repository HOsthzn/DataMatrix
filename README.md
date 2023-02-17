# DataMatrix

DataMatrix is a dynamic data warehousing system created in T-SQL. The dbo schema is responsible for user management and
data warehouse management. It has the following 5 tables that track and maintain the warehouse:

### dbo.DataTypes

| Column Name    | Data Type      | 	Constraints |
|----------------|----------------|--------------|
| Id             | NVARCHAR(128)  | PRIMARY KEY  |
| Name           | VARCHAR(128)   | NOT NULL     |
| Code           | VARCHAR(10)    | NOT NULL     |
| Type           | VARCHAR(256)   | NOT NULL     |
| Description    | VARCHAR(MAX)   |              |
| Size           | VARCHAR(256)   |              |
| DateTimeFormat | VARCHAR(256)   |              |
| MaxValue       | DECIMAL(18, 6) |              |
| MinValue       | DECIMAL(18, 6) |              |

This table stores information about data types that are used in the warehouse. The Id column is the primary key, and the
Code and Name columns have unique indexes.

| Id      | Name                     | 	Code  | Type       | 	Description                | 	Size | DateTimeFormat   | 	MaxValue | MinValue |
|---------|--------------------------|--------|------------|-----------------------------|-------|------------------|-----------|----------|
| newid() | 	BIT                     | 	BIT   | 	BIT       | 	DEFAULT BIT TYPE           | null  | null             | null      | null     |
| newid() | 	VARCHAR                 | 	VAR   | 	VARCHAR   | 	DEFAULT string VALUE       | 256   | null             | null      | null     |
| newid() | 	HASH                    | 	HASH  | 	NVARCHAR  | 	DEFAULT HASH VALUE         | MAX   | null             | null      | null     |
| newid() | 	INTEGER                 | 	INT   | 	INT       | 	DEFAULT INT TYPE           | null  | null             | null      | null     |
| newid() | 	DECIMAL                 | 	DEC   | 	DECIMAL   | 	DEFAULT DECIMAL TYPE       | 18,6  | null             | null      | null     |
| newid() | 	Phone Number            | 	PNUM  | 	NVARCHAR  | 	DEFAULT phone number VALUE | MAX   | null             | null      | null     |
| newid() | 	DATETIME                | 	DT    | 	DATETIME2 | 	DEFAULT DATETIME TYPE      | null  | DD-MM-YYYY HH:MM | null      | null     |
| newid() | 	DESCRIPTION             | 	DESC  | 	VARCHAR   | 	DEFAULT DESCRIPTION VALUE  | MAX   | null             | null      | null     |
| newid() | 	Email                   | 	EMAIL | 	NVARCHAR  | 	DEFAULT email VALUE	       | 256   | null             | null      | null     |
| newid() | 	PRIMARY KEY/FOREIGN KEY | 	PK    | 	NVARCHAR  | 	DEFAULT PRIMARY KEY TYPE   | 128   | null             | null      | null     |

- Id: A unique identifier for each data type
- Name: The name of the data type
- Code: A code used to reference the data type
- Type: The SQL Server data type for the data type
- Description: A brief description of the data type
- Size: The maximum size of the data type (if applicable)
- DateTimeFormat: The format for date and time data types (if applicable)
- MaxValue: The maximum value for the data type (if applicable)
- MinValue: The minimum value for the data type (if applicable)

These default data types provide a basic set of data types for use in the database. They include common data types such
as BIT, VARCHAR, INTEGER, and DECIMAL, as well as more specialized data types such as Phone Number, Email, and PRIMARY
KEY/FOREIGN KEY. These data types can be used as-is or customized to fit the needs of the database.

### dbo.Schemas

| Column Name | 	Data Type	    | Constraints  |
|-------------|----------------|--------------|
| Id          | 	NVARCHAR(128) | 	PRIMARY KEY |
| Name        | 	VARCHAR(256)  | 	NOT NULL    |

This table stores information about schemas in the warehouse. The Id column is the primary key, and the Name column has
a unique index.

### dbo.Tables

| Column Name | 	Data Type     | 	Constraints                                               |
|-------------|----------------|------------------------------------------------------------|
| Id          | 	NVARCHAR(128) | 	PRIMARY KEY                                               | NONCLUSTERED |
| SchemaId    | 	NVARCHAR(128) | 	NOT NULL FOREIGN KEY to dbo.Schemas(Id) ON DELETE CASCADE |
| Name        | 	VARCHAR(256)  | 	NOT NULL                                                  |
| WithAudits  | 	BIT           | 	NOT NULL, DEFAULT 1                                       |
| AlterDate   | 	DATETIME2     | 	NOT NULL, DEFAULT GETDATE()                               |

This table stores information about tables in the warehouse. The Id column is the primary key, and the SchemaId column
is a foreign key to the dbo.Schemas table with cascade delete. The Name column has a unique index.

### dbo.TableColumns

| Column Name           | 	Data Type     | 	Constraints                                                  |
|-----------------------|----------------|---------------------------------------------------------------|
| Id                    | 	NVARCHAR(128) | 	PRIMARY KEY NONCLUSTERED                                     |
| TableId               | 	NVARCHAR(128) | 	NOT NULL, FOREIGN KEY to dbo.Tables(Id) ON DELETE CASCADE    |
| DataTypeId            | 	NVARCHAR(128) | 	NOT NULL, FOREIGN KEY to dbo.DataTypes(Id) ON DELETE CASCADE |
| Name                  | 	VARCHAR(256)  | 	NOT NULL                                                     |
| DefaultValue          | 	NVARCHAR(MAX) |
| NotNull               | 	BIT	          | NOT NULL, DEFAULT 0                                           |
| IsPrimaryKey          | 	BIT           | 	NOT NULL, DEFAULT 0                                          |
| IsForeignKey          | 	BIT           | 	NOT NULL, DEFAULT 0                                          |
| IsForeignDisplayValue | 	BIT           | 	NOT NULL, DEFAULT 0                                          |
| OrdinalPosition       | 	INT           | 	NOT NULL                                                     |
| DisplayInGrid         | 	BIT           | 	NOT NULL, DEFAULT 0                                          |
| AlterDate             | 	DATETIME2     | NOT NULL, DEFAULT GETDATE()                                   |

This table stores information about columns in the warehouse tables. The Id column is the primary key, and the TableId
and DataTypeId columns are foreign keys to the `
