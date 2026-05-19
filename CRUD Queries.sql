-- Think of an SP as a function in Java.
--   Input: Parameters (e.g., UserID).
--   Logic: The SQL command inside.
--   Output: A result set or success message.

-- using Restaurant.Profiles table for these examples.
USE FoodDeliveryDB;
GO

-- A. Select (Read)
-- This retrieves details for a specific restaurant.
CREATE PROCEDURE Restaurant.GetRestaurantDetails
    @RestaurantID INT
AS
BEGIN
    SELECT Name, Phone, Rating, IsOpen, IsVeg
    FROM Restaurant.Profiles
    WHERE RestaurantID = @RestaurantID;
END;
GO

-- To Read
EXEC Restaurant.GetRestaurantDetails @RestaurantID = 1;

-------------------------------------------+++-----------------------------------------------

-- B. Insert (Create)
-- This adds a new restaurant securely.
GO
CREATE PROCEDURE Restaurant.AddNewRestaurant
    @Name NVARCHAR(150),
    @Phone NVARCHAR(15),
    @LicenceNo NVARCHAR(50),
    @IsVeg BIT
AS
BEGIN
    INSERT INTO Restaurant.Profiles (Name, Phone, Rating, IsOpen, LicenceNo, IsVeg)
    VALUES (@Name, @Phone, 4.0, 1, @LicenceNo, @IsVeg);
END;
GO

-- To Insert
EXEC Restaurant.AddNewRestaurant 'New Cafe', '9999999999', 'LIC999', 1;

-------------------------------------------+++-----------------------------------------------

-- C. Update
-- This updates the availability status of a restaurant.
GO
CREATE PROCEDURE Restaurant.UpdateRestaurantStatus
    @RestaurantID INT,
    @IsOpen BIT
AS
BEGIN
    UPDATE Restaurant.Profiles
    SET IsOpen = @IsOpen
    WHERE RestaurantID = @RestaurantID;
END;
GO

-- To Update
EXEC Restaurant.UpdateRestaurantStatus @RestaurantID = 1, @IsOpen = 0;

-------------------------------------------+++-----------------------------------------------

-- D. Delete
-- This removes a record.
GO
CREATE PROCEDURE Restaurant.RemoveRestaurant
    @RestaurantID INT
AS
BEGIN
    DELETE FROM Restaurant.Profiles
    WHERE RestaurantID = @RestaurantID;
END;
GO

-- To Update
EXEC Restaurant.RemoveRestaurant @RestaurantID = 1;

-------------------------------------------+++-----------------------------------------------

-- Insert a test restaurant
EXEC Restaurant.AddNewRestaurant 'Test Cafe', '0000000000', 'T-123', 1;
-- Check if it was inserted
SELECT * FROM Restaurant.Profiles WHERE Name = 'Test Cafe';
-------------------------------------------+++-----------------------------------------------
-- Update it
DECLARE @NewID INT = (SELECT TOP 1 RestaurantID FROM Restaurant.Profiles WHERE Name = 'Test Cafe');
EXEC Restaurant.UpdateRestaurantStatus @RestaurantID = @NewID, @IsOpen = 0;
-- Verify the update
SELECT IsOpen FROM Restaurant.Profiles WHERE RestaurantID = @NewID;
-------------------------------------------+++-----------------------------------------------
-- this system query to see a list of all procedures you've created:
SELECT name, create_date, modify_date 
FROM sys.procedures;
-------------------------------------------+++-----------------------------------------------
-- "Try-Catch" Example
CREATE PROCEDURE Restaurant.UpdateRestaurantStatus_Safe
    @RestaurantID INT,
    @IsOpen BIT
AS
BEGIN
    BEGIN TRY
        UPDATE Restaurant.Profiles
        SET IsOpen = @IsOpen
        WHERE RestaurantID = @RestaurantID;
        
        PRINT 'Update successful!';
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
-------------------------------------------+++-----------------------------------------------
-- Stored Procedure that calculates the "Total Revenue" for a specific restaurant ID

CREATE PROCEDURE Restaurant.GetRestaurantRevenue
    @RestaurantID INT
AS
BEGIN
    SET NOCOUNT ON; -- Prevents extra messages from being returned to the app
    
    BEGIN TRY
        -- Check if restaurant exists first
        IF NOT EXISTS (SELECT 1 FROM Restaurant.Profiles WHERE RestaurantID = @RestaurantID)
        BEGIN
            PRINT 'Error: Restaurant ID does not exist.';
            RETURN;
        END

        -- Execute the revenue calculation
        SELECT 
            R.Name AS RestaurantName,
            SUM(O.TotalAmount) AS TotalRevenue,
            COUNT(O.OrderID) AS TotalOrdersServed
        FROM Restaurant.Profiles R
        JOIN [Order].Transactions O ON R.RestaurantID = O.RestaurantID
        WHERE R.RestaurantID = @RestaurantID
        GROUP BY R.Name;

    END TRY
    BEGIN CATCH
        -- Log the error details for the developer
        PRINT 'An error occurred in GetRestaurantRevenue: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

-- Test it for Restaurant ID 1 (e.g., Empire Restaurant)
EXEC Restaurant.GetRestaurantRevenue @RestaurantID = 1;
