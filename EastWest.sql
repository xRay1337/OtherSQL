IF (SELECT DB_ID('EastWest')) IS NOT NULL
BEGIN
	EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'EastWest'
	ALTER DATABASE EastWest SET SINGLE_USER WITH ROLLBACK IMMEDIATE
	USE "master"
	DROP DATABASE EastWest
END

CREATE DATABASE EastWest
USE EastWest
GO
CREATE SCHEMA Sales
GO
CREATE SCHEMA Dim
GO

CREATE TABLE Dim.Branches
(
	BranchId	INT IDENTITY(1, 1)	NOT NULL,
	BranchName	NVARCHAR(128)		NOT NULL,
	CONSTRAINT PkBranchesBranchId PRIMARY KEY (BranchId)
)

CREATE TABLE Dim.Clients
(
	ClientId	INT IDENTITY(1, 1)	NOT NULL,
	ClientName	NVARCHAR(128)		NOT NULL,
	BranchId	INT					NULL,
	CONSTRAINT PkClientsClientId PRIMARY KEY (ClientId),
	CONSTRAINT FkClientsBranchId FOREIGN KEY (BranchId) REFERENCES Dim.Branches(BranchId)
)

CREATE TABLE Dim.Sources
(
	SourceId	INT IDENTITY(1, 1)	NOT NULL,
	SourceName	NVARCHAR(32)		NOT NULL,
	CONSTRAINT PkSourcesSourceId PRIMARY KEY (SourceId)
)

CREATE TABLE Dim.Formats
(
	FormatId	INT IDENTITY(1, 1)	NOT NULL,
	FormatName	NVARCHAR(8)			NOT NULL,
	CONSTRAINT PkFormats PRIMARY KEY (FormatId)
)

CREATE TABLE Sales.Orders
(
	OrderId				INT IDENTITY(1, 1)	NOT NULL,
	OrderDate			DATETIME2(7)		NOT NULL DEFAULT SYSDATETIME(),
	ClientId			INT					NOT NULL,	
	DesiredDeliveryDate	DATETIME2(0)		NOT NULL,
	SourceId			INT					NOT NULL,
	FormatId			INT					NOT NULL,
	XmlValue			XML					NULL,
	ValuePath			NVARCHAR(256)		NULL,
	CONSTRAINT PkOrdersOrderId	PRIMARY KEY (OrderId),
	CONSTRAINT FkOrdersClientId FOREIGN KEY (ClientId) REFERENCES Dim.Clients(ClientId),
	CONSTRAINT FkOrdersSourceId FOREIGN KEY (SourceId) REFERENCES Dim.Sources(SourceId),
	CONSTRAINT FkOrdersFormatId FOREIGN KEY (FormatId) REFERENCES Dim.Formats(FormatId),
	CONSTRAINT CheckOnlyOneColumnIsNull CHECK ((IIF(XmlValue IS NULL, 0, 1) + IIF(ValuePath IS NULL, 0, 1) = 1))
)

CREATE TABLE Sales.OrderDetails
(
	OrderId		INT				NOT NULL,
	OrderLineId	INT				NOT NULL,
	Unit		NVARCHAR(8)		NOT NULL,
	Quantity	INT				NOT NULL,
	CONSTRAINT PkOrderDetailsOrderIdOrderLineId	PRIMARY KEY (OrderId, OrderLineId),
	CONSTRAINT FkOrderDetailsOrderId			FOREIGN KEY (OrderId) REFERENCES Sales.Orders(OrderId)
)
