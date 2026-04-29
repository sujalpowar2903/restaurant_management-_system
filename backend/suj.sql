CREATE DATABASE SalesDB;
USE SalesDB;


CREATE TABLE Client (
    Client_No VARCHAR(10) PRIMARY KEY,
    Name VARCHAR(50),
    Address VARCHAR(100),
    City VARCHAR(50),
    Pincode INT
);


CREATE TABLE Products (
    product_no VARCHAR(10) PRIMARY KEY,
    description VARCHAR(50),
    price INT
);


CREATE TABLE Orders (
    order_no INT PRIMARY KEY,
    client_no VARCHAR(10),
    order_date DATE,
    FOREIGN KEY (client_no) REFERENCES Client(Client_No)
);


CREATE TABLE Order_Details (
    order_no INT,
    product_no VARCHAR(10),
    qty INT,
    PRIMARY KEY (order_no, product_no),
    FOREIGN KEY (order_no) REFERENCES Orders(order_no),
    FOREIGN KEY (product_no) REFERENCES Products(product_no)
);

INSERT INTO Client VALUES
('C01','Sujal','Kolhapur','Pune',411001),
('C02','Raj','Mumbai','Mumbai',400001),
('C03','Atharva','Nashik','Nashik',422001),
('C04','Suraj','Dhule','Dhule',424001),
('C05','Harshwardhan','Pune','Pune',411002),
('C06','Samarth','Mumbai','Mumbai',400002),
('C07','Puru','Nashik','Nashik',422002),
('C08','Aryan','Pune','Pune',411003);


INSERT INTO Products VALUES
('P01','Shirt',500),
('P02','Track pant',300),
('P03','Jeans',1200),
('P04','Jacket',2000);


INSERT INTO Orders VALUES
(1,'C01','2026-06-10'),
(2,'C02','2026-06-15'),
(3,'C03','2026-05-20'),
(4,'C04','2026-06-18'),
(5,'C05','2026-06-20'),
(7,'C07','2026-06-12'),
(8,'C08','2026-06-28');


INSERT INTO Order_Details VALUES
(1,'P01',3),
(1,'P02',2),
(2,'P01',6),
(2,'P03',1),
(3,'P04',2),
(4,'P01',4),
(5,'P02',5),
(7,'P01',1),
(8,'P02',3);