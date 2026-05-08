/* ============================================================================================================================
   PROJECT   : Retail Business Analysis 
   DATABASE  : RetailVendorInventoryDB
   TOOL      : SQL Server
   PURPOSE   : Data Analysis on cleaned exported data from Python
   ============================================================================================================================ 
*/




-- ----------------------------------------------------------------------------------------------------------------------------
-- SETUP : Create Database & Table
-- ----------------------------------------------------------------------------------------------------------------------------


CREATE DATABASE RetailVendorInventoryDB;
GO

USE RetailVendorInventoryDB;
GO

DROP TABLE IF EXISTS dbo.clean_sales;

CREATE TABLE dbo.clean_sales (
    InventoryId       NVARCHAR(100),
    Store             INT,
    Brand             INT,
    Description       NVARCHAR(255),
    Size              NVARCHAR(50),
    SalesQuantity     DECIMAL(18,2),
    SalesDollars      DECIMAL(18,2),
    SalesPrice        DECIMAL(18,2),
    SalesDate         DATE,
    Volume            DECIMAL(18,2),
    Classification    INT,
    ExciseTax         DECIMAL(18,2),
    VendorNo          INT,
    VendorName        NVARCHAR(255)
);


DROP TABLE IF EXISTS dbo.clean_purchases;

CREATE TABLE dbo.clean_purchases (
    InventoryId       NVARCHAR(100),
    Store             INT,
    Brand             INT,
    Description       NVARCHAR(255),
    Size              NVARCHAR(50),
    VendorNumber      INT,
    VendorName        NVARCHAR(255),
    PONumber          INT,
    PODate            DATE,
    ReceivingDate     DATE,
    InvoiceDate       DATE,
    PayDate           DATE,
    PurchasePrice     DECIMAL(18,2),
    Quantity          DECIMAL(18,2),
    Dollars           DECIMAL(18,2),
    Classification    INT
);


DROP TABLE IF EXISTS dbo.clean_purchase_prices;

CREATE TABLE dbo.clean_purchase_prices (
    Brand             INT,
    Description       NVARCHAR(255),
    Price             DECIMAL(18,2),
    Size              NVARCHAR(50),
    Volume            DECIMAL(18,2),
    Classification    INT,
    PurchasePrice     DECIMAL(18,2),
    VendorNumber      INT,
    VendorName        NVARCHAR(255)
);


DROP TABLE IF EXISTS dbo.clean_vendor_invoice;

CREATE TABLE dbo.clean_vendor_invoice (
    VendorNumber      INT,
    VendorName        NVARCHAR(255),
    InvoiceDate       DATE,
    PONumber          INT,
    PODate            DATE,
    PayDate           DATE,
    Quantity          DECIMAL(18,2),
    Dollars           DECIMAL(18,2),
    Freight           DECIMAL(18,2)
);


DROP TABLE IF EXISTS dbo.clean_begin_inventory;

CREATE TABLE dbo.clean_begin_inventory (
    InventoryId               NVARCHAR(100),
    Store                     INT,
    City                      NVARCHAR(100),
    Brand                     INT,
    Description               NVARCHAR(255),
    Size                      NVARCHAR(50),
    onHand                    DECIMAL(18,2),
    Price                     DECIMAL(18,2),
    startDate                 DATE,
    BeginningInventoryValue   DECIMAL(18,2)
);


DROP TABLE IF EXISTS dbo.clean_end_inventory;

CREATE TABLE dbo.clean_end_inventory (
    InventoryId             NVARCHAR(100),
    Store                   INT,
    City                    NVARCHAR(100),
    Brand                   INT,
    Description             NVARCHAR(255),
    Size                    NVARCHAR(50),
    onHand                  DECIMAL(18,2),
    Price                   DECIMAL(18,2),
    endDate                 DATE,
    EndingInventoryValue    DECIMAL(18,2)
);

BULK INSERT dbo.clean_sales
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);


BULK INSERT dbo.clean_purchases
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_purchases.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.clean_purchase_prices
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_purchase_prices.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.clean_vendor_invoice
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_vendor_invoice.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.clean_begin_inventory
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_begin_inventory.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);

BULK INSERT dbo.clean_end_inventory
FROM 'C:\Users\tamir\OneDrive\Desktop\VendorProjectMY\cleaned_data\clean_end_inventory.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    TABLOCK
);