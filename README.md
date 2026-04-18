Restaurant Management System (DBMS Mini Project)
📌 Project Overview

The Restaurant Management System is a database-driven application designed to manage restaurant operations efficiently. It helps in handling orders, customers, menu items, billing, and staff details using a structured database system.

This project is built as part of the Database Management System (DBMS) curriculum to demonstrate concepts like normalization, relationships, and SQL queries.

🎯 Objectives
To manage restaurant orders digitally
To maintain customer and billing records
To reduce manual errors and improve efficiency
To implement DBMS concepts in a real-world scenario
🛠️ Technologies Used
Frontend: HTML, CSS, JavaScript
Backend: Node.js / PHP (depending on your project)
Database: MySQL
Tools: VS Code, XAMPP / Local Server



🗂️ Features
👤 Customer Management
🍜 Menu Management
🧾 Order Processing
💳 Billing System
👨‍🍳 Staff Management
📊 Reports & Data Analysis
🧩 Database Design


📌 Tables Used
Customers (CustomerID, Name, Contact, Address)
Menu (ItemID, ItemName, Price, Category)
Orders (OrderID, CustomerID, Date, TotalAmount)
OrderDetails (OrderID, ItemID, Quantity)
Staff (StaffID, Name, Role, Salary)
🔗 Relationships
One Customer → Many Orders
One Order → Many Items
Many Items → Many Orders (via OrderDetails)


⚙️ Installation & Setup
1️⃣ Clone Repository
git clone https://github.com/your-username/restaurant-management.git
cd restaurant-management
2️⃣ Setup Database
Open MySQL
Create database:
CREATE DATABASE restaurant_db;
Import the SQL file:
SOURCE restaurant.sql;
3️⃣ Run Project
Start XAMPP / Server
Open browser:
http://localhost:5000
📸 Screenshots

(Add your project screenshots here)

📊 Sample Queries
-- Get all orders
SELECT * FROM Orders;

-- Total revenue
SELECT SUM(TotalAmount) FROM Orders;

-- Most ordered item
SELECT ItemID, COUNT(*) 
FROM OrderDetails 
GROUP BY ItemID 
ORDER BY COUNT(*) DESC;
🚧 Future Enhancements
Online ordering system
Payment gateway integration
Mobile app support
AI-based recommendations
👨‍💻 Author
Your Name
College Name
Course: DBMS
📜 License

This project is for educational purposes only.

⭐ Acknowledgement

Special thanks to faculty and resources that helped in completing this project.
