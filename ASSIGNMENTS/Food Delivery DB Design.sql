
-- Food Delivery App Database Design(like Zomato)

-- 2. Users Table (Customer Details)
CREATE TABLE Users (
    UserID INT PRIMARY KEY IDENTITY(1,1),
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Phone NVARCHAR(15) NOT NULL,
    CreatedAt DATETIME DEFAULT GETDATE()
);

-- 3. Addresses Table (Normalization: Users can have multiple addresses)
CREATE TABLE UserAddresses (
    AddressID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    AddressLine NVARCHAR(MAX),
    City NVARCHAR(50),
    Pincode NVARCHAR(10),
    AddressType NVARCHAR(20) -- e.g., 'Home', 'Work'
);

-- 4. Restaurants Table
CREATE TABLE Restaurants (
    RestaurantID INT PRIMARY KEY IDENTITY(1,1),
    ResName NVARCHAR(100) NOT NULL,
    ResAddress NVARCHAR(MAX),
    ContactNo NVARCHAR(15),
    Rating DECIMAL(2,1) CHECK (Rating <= 5.0)
);

-- 5. DeliveryPartners Table (Renamed from DeliveryBoy)
CREATE TABLE DeliveryPartners (
    PartnerID INT PRIMARY KEY IDENTITY(1,1),
    PartnerName NVARCHAR(100),
    Phone NVARCHAR(15),
    Email NVARCHAR(100),
    Rating DECIMAL(2,1),
    JoiningDate DATE DEFAULT CAST(GETDATE() AS DATE),
    IsActive BIT DEFAULT 1
);

-- 6. MenuItems Table
CREATE TABLE MenuItems (
    ItemID INT PRIMARY KEY IDENTITY(1,1),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    ItemName NVARCHAR(100),
    Category NVARCHAR(50), -- e.g., 'Starter', 'Main Course'
    Price DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(MAX)
);

-- 7. Orders Table (Header info only)
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    UserID INT FOREIGN KEY REFERENCES Users(UserID),
    RestaurantID INT FOREIGN KEY REFERENCES Restaurants(RestaurantID),
    PartnerID INT FOREIGN KEY REFERENCES DeliveryPartners(PartnerID),
    OrderStatus NVARCHAR(20), -- 'Pending', 'Confirmed', 'Delivered'
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2)
);

-- 8. OrderDetails Table (Crucial for 3NF - Handles multiple items per order)
CREATE TABLE OrderDetails (
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    ItemID INT FOREIGN KEY REFERENCES MenuItems(ItemID),
    Quantity INT NOT NULL,
    PriceAtTime DECIMAL(10,2) -- Prevents old bills from changing if menu price updates
);

-- 9. Payments/Bills Table
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY IDENTITY(1,1),
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID),
    PaymentMode NVARCHAR(20), -- 'UPI', 'Card', 'COD'
    TaxAmount DECIMAL(10,2),
    DeliveryCharge DECIMAL(10,2),
    FinalTotal DECIMAL(10,2),
    PaymentStatus NVARCHAR(20)
);





-- 1. Insert Users
INSERT INTO Users (FullName, Email, Phone)
VALUES ('Rahul Sharma', 'rahul@email.com', '9876543210'),
       ('Priya Kapoor', 'priya@email.com', '9988776655');

-- 2. Insert Restaurants
INSERT INTO Restaurants (ResName, ResAddress, ContactNo, Rating)
VALUES ('The Pizza Project', 'MG Road, Bangalore', '080-12345', 4.5),
       ('Spice Garden', 'Indiranagar, Bangalore', '080-67890', 4.2);

-- 3. Insert Delivery Partners
INSERT INTO DeliveryPartners (PartnerName, Phone, Email, Rating)
VALUES ('Amit Kumar', '9000011111', 'amit.d@zomato.com', 4.9),
       ('Suresh V', '9000022222', 'suresh.v@zomato.com', 4.7);

-- 4. Insert Menu Items
INSERT INTO MenuItems (RestaurantID, ItemName, Category, Price, Description)
VALUES (1, 'Margherita Pizza', 'Main Course', 299.00, 'Classic cheese and tomato'),
       (1, 'Garlic Bread', 'Starter', 120.00, 'Buttery garlic goodness'),
       (2, 'Paneer Butter Masala', 'Main Course', 250.00, 'Rich creamy paneer curry');

-- 5. Insert an Order
-- (Rahul orders a Pizza and Garlic Bread from The Pizza Project)
INSERT INTO Orders (UserID, RestaurantID, PartnerID, OrderStatus, TotalAmount)
VALUES (1, 1, 1, 'Delivered', 419.00);

-- 6. Insert Order Details (The breakdown of the order)
INSERT INTO OrderDetails (OrderID, ItemID, Quantity, PriceAtTime)
VALUES (1, 1, 1, 299.00), -- 1 Pizza
       (1, 2, 1, 120.00); -- 1 Garlic Bread

-- 7. Insert Payment record
INSERT INTO Payments (OrderID, PaymentMode, TaxAmount, DeliveryCharge, FinalTotal, PaymentStatus)
VALUES (1, 'UPI', 20.95, 30.00, 469.95, 'Success');




SELECT 
    o.OrderID,
    u.FullName AS Customer,
    r.ResName AS Restaurant,
    mi.ItemName,
    od.Quantity,
    od.PriceAtTime AS UnitPrice,
    (od.Quantity * od.PriceAtTime) AS SubTotal,
    p.PaymentMode,
    p.FinalTotal AS GrandTotal,
    dp.PartnerName AS DeliveredBy
FROM Orders o
JOIN Users u ON o.UserID = u.UserID
JOIN Restaurants r ON o.RestaurantID = r.RestaurantID
JOIN OrderDetails od ON o.OrderID = od.OrderID
JOIN MenuItems mi ON od.ItemID = mi.ItemID
JOIN Payments p ON o.OrderID = p.OrderID
JOIN DeliveryPartners dp ON o.PartnerID = dp.PartnerID;