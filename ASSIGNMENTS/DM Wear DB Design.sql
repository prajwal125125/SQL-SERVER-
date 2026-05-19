
-- DM Wear - Clothing retail store database design...

-- 1. TAXES TABLE
CREATE TABLE Taxes (
    TaxID INT PRIMARY KEY IDENTITY(1,1),
    TaxName VARCHAR(50) NOT NULL,
    Percentage DECIMAL(5, 2) NOT NULL CHECK (Percentage >= 0)
);


-- 2. CUSTOMERS TABLE
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    CustomerName VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) UNIQUE NOT NULL,
    Email VARCHAR(100),
    CreatedAt DATETIME DEFAULT GETDATE()
);


-- 3. EMPLOYEES TABLE
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    EmployeeName VARCHAR(100) NOT NULL,
    Role VARCHAR(50) NOT NULL
);


-- 4. PRODUCTS TABLE
CREATE TABLE Products (
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Brand VARCHAR(50),
    Category VARCHAR(50)
);

-- 5. PRODUCT VARIANTS TABLE (With IDENTITY and SKU)
CREATE TABLE ProductVariants (
    VariantID INT PRIMARY KEY IDENTITY(1,1),
    ProductID INT NOT NULL,
    SKU VARCHAR(50) UNIQUE NOT NULL, 
    Size VARCHAR(10) NOT NULL,
    Color VARCHAR(20) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL CHECK (Price >= 0),
    StockQuantity INT DEFAULT 0 CHECK (StockQuantity >= 0),
    CONSTRAINT FK_ProductVariants_Products FOREIGN KEY (ProductID) 
        REFERENCES Products(ProductID) ON DELETE CASCADE
);


-- 6. BILLS TABLE
CREATE TABLE Bills (
    BillID INT PRIMARY KEY IDENTITY(1,1),
    CustomerID INT, 
    EmployeeID INT NOT NULL,
    BillDate DATETIME DEFAULT GETDATE(),
    SubTotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    TotalTax DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    GrandTotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT FK_Bills_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_Bills_Employees FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);


-- 7. BILL DETAILS TABLE
CREATE TABLE BillDetails (
    BillDetailID INT PRIMARY KEY IDENTITY(1,1),
    BillID INT NOT NULL,
    VariantID INT NOT NULL,
    TaxID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPriceAtSale DECIMAL(10, 2) NOT NULL,
    DiscountAmount DECIMAL(10, 2) DEFAULT 0.00 CHECK (DiscountAmount >= 0),
    LineTotal DECIMAL(10, 2) NOT NULL,
    CONSTRAINT FK_Details_Bill FOREIGN KEY (BillID) REFERENCES Bills(BillID) ON DELETE CASCADE,
    CONSTRAINT FK_Details_Variant FOREIGN KEY (VariantID) REFERENCES ProductVariants(VariantID),
    CONSTRAINT FK_Details_Tax FOREIGN KEY (TaxID) REFERENCES Taxes(TaxID)
);


-- 8. PAYMENTS TABLE (SQL Server compatible CHECK for Method)
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    BillID INT NOT NULL,
    PaymentMethod VARCHAR(20) NOT NULL 
        CHECK (PaymentMethod IN ('Cash', 'Card', 'UPI', 'Store Credit')),
    AmountPaid DECIMAL(10, 2) NOT NULL CHECK (AmountPaid > 0),
    PaymentTime DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Payments_Bill FOREIGN KEY (BillID) REFERENCES Bills(BillID)
);

-- Indexes for performance
CREATE INDEX idx_product_name ON Products(ProductName);
CREATE INDEX idx_bill_date ON Bills(BillDate);





-- Insert Tax Rates
INSERT INTO Taxes(TaxName, Percentage) VALUES ('GST_5', 5.00), ('GST_12', 12.00), ('Zero_Tax', 0.00);

-- Insert Sample Customers
INSERT INTO Customers(CustomerName, Phone, Email) 
VALUES ('Yogesh Rebari', '9876543210', 'yogesh@email.com'),
       ('Anil Rebri', '9887766554', 'anil@email.com');

-- Insert Staff
INSERT INTO Employees(EmployeeName, Role) 
VALUES ('Admin User', 'Manager'), ('Sales Staff 1', 'Cashier');


-- Insert a Base Product
INSERT INTO Products(ProductName, Brand, Category) 
VALUES ('Slim Fit Jeans', 'Levi s', 'Denim');

-- Insert Variants (The actual items on the shelf)
-- Using ID 1 from the Products table above
INSERT INTO ProductVariants(ProductID, SKU, Size, Color, Price, StockQuantity)
VALUES (1, 'LEV-JS-BLU-32', '32', 'Blue', 2499.00, 50),
       (1, 'LEV-JS-BLU-34', '34', 'Blue', 2499.00, 35),
       (1, 'LEV-JS-BLK-32', '32', 'Black', 2699.00, 20);


-- 1. Create the Bill Header
INSERT INTO Bills(CustomerID, EmployeeID, SubTotal, TotalTax, GrandTotal)
VALUES (1, 2, 4898.00, 244.90, 5142.90);

-- 2. Add the Line Item (Linking to BillID 1 and VariantID 1)
INSERT INTO BillDetails(BillID, VariantID, TaxID, Quantity, UnitPriceAtSale, DiscountAmount, LineTotal)
VALUES (1, 1, 1, 2, 2499.00, 100.00, 4898.00);

-- 3. Record the Payment
INSERT INTO Payments(BillID, PaymentMethod, AmountPaid)
VALUES (1, 'UPI', 5142.90);


SELECT 
    B.BillID,
    C.CustomerName,
    P.ProductName,
    PV.SKU,
    PV.Size,
    BD.Quantity,
    BD.LineTotal,
    T.TaxName,
    (BD.LineTotal * T.Percentage / 100) AS CalculatedTax,
    PY.PaymentMethod
FROM Bills B
JOIN Customers C ON B.CustomerID = C.CustomerID
JOIN BillDetails BD ON B.BillID = BD.BillID
JOIN ProductVariants PV ON BD.VariantID = PV.VariantID
JOIN Products P ON PV.ProductID = P.ProductID
JOIN Taxes T ON BD.TaxID = T.TaxID
JOIN Payments PY ON B.BillID = PY.BillID;

