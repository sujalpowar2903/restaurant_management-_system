CREATE DATABASE IF NOT EXISTS restaurant_management;
USE restaurant_management;

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role ENUM('manager', 'chef', 'waiter', 'cashier', 'host') NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100) UNIQUE,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS tables (
    table_id INT PRIMARY KEY AUTO_INCREMENT,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL,
    location VARCHAR(50),
    status ENUM('available', 'occupied', 'reserved', 'maintenance') DEFAULT 'available'
);

CREATE TABLE IF NOT EXISTS menu_categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL,
    description TEXT,
    display_order INT DEFAULT 0
);

CREATE TABLE IF NOT EXISTS menu_items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    category_id INT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    cost_price DECIMAL(10, 2),
    preparation_time INT,
    is_vegetarian BOOLEAN DEFAULT FALSE,
    is_available BOOLEAN DEFAULT TRUE,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES menu_categories(category_id)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(15),
    email VARCHAR(100),
    loyalty_points INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS reservations (
    reservation_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    table_id INT,
    reservation_date DATE NOT NULL,
    reservation_time TIME NOT NULL,
    party_size INT NOT NULL,
    status ENUM('pending', 'confirmed', 'seated', 'completed', 'cancelled') DEFAULT 'pending',
    special_requests TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (table_id) REFERENCES tables(table_id)
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    table_id INT,
    customer_id INT,
    employee_id INT,
    order_type ENUM('dine-in', 'takeaway', 'delivery') DEFAULT 'dine-in',
    status ENUM('pending', 'preparing', 'ready', 'served', 'completed', 'cancelled') DEFAULT 'pending',
    subtotal DECIMAL(10, 2) DEFAULT 0,
    tax_amount DECIMAL(10, 2) DEFAULT 0,
    discount_amount DECIMAL(10, 2) DEFAULT 0,
    total_amount DECIMAL(10, 2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (table_id) REFERENCES tables(table_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    status ENUM('pending', 'preparing', 'ready', 'served') DEFAULT 'pending',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_method ENUM('cash', 'credit_card', 'debit_card', 'upi', 'wallet') NOT NULL,
    payment_status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    transaction_id VARCHAR(100),
    paid_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE IF NOT EXISTS inventory (
    inventory_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    quantity DECIMAL(10, 2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    reorder_level DECIMAL(10, 2),
    cost_per_unit DECIMAL(10, 2),
    supplier VARCHAR(100),
    last_restocked DATE,
    expiry_date DATE
);

CREATE TABLE IF NOT EXISTS menu_item_ingredients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    inventory_id INT NOT NULL,
    quantity_required DECIMAL(10, 3) NOT NULL,
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id),
    FOREIGN KEY (inventory_id) REFERENCES inventory(inventory_id)
);

SET FOREIGN_KEY_CHECKS = 1;

-- VIEWS
CREATE OR REPLACE VIEW daily_sales_summary AS
SELECT
    DATE(created_at) AS sale_date,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS total_revenue,
    AVG(total_amount) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY DATE(created_at);

CREATE OR REPLACE VIEW popular_items AS
SELECT
    mi.item_name,
    mc.category_name,
    COUNT(oi.order_item_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold
FROM order_items oi
JOIN menu_items mi ON oi.item_id = mi.item_id
JOIN menu_categories mc ON mi.category_id = mc.category_id
GROUP BY mi.item_id
ORDER BY times_ordered DESC;

-- CLEAR OLD DATA
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE order_items;
TRUNCATE TABLE orders;
TRUNCATE TABLE menu_items;
TRUNCATE TABLE menu_categories;
TRUNCATE TABLE tables;
SET FOREIGN_KEY_CHECKS = 1;

-- SAMPLE DATA
INSERT INTO menu_categories (category_name, description, display_order) VALUES
('Starter',     'Appetizers',  1),
('Main Course', 'Main dishes', 2),
('Dessert',     'Sweet items', 3);

INSERT INTO tables (table_number, capacity, location, status) VALUES
(1, 4, 'main hall',    'available'),
(2, 2, 'patio',        'available'),
(3, 6, 'private room', 'available'),
(4, 4, 'main hall',    'available'),
(5, 8, 'banquet',      'available');

INSERT INTO menu_items (category_id, item_name, description, price, cost_price, preparation_time, is_vegetarian, is_available) VALUES
(1, 'Spring Rolls',    'Crispy veggie rolls',       120.00,  40.00, 10, TRUE,  TRUE),
(1, 'Soup of the Day', 'Chef special soup',          90.00,  25.00,  8, TRUE,  TRUE),
(1, 'Chicken Wings',   'Spicy grilled wings',       150.00,  60.00, 15, FALSE, TRUE),
(2, 'Butter Chicken',  'Creamy tomato curry',       280.00,  90.00, 20, FALSE, TRUE),
(2, 'Paneer Tikka',    'Grilled cottage cheese',    220.00,  70.00, 18, TRUE,  TRUE),
(2, 'Dal Makhani',     'Slow cooked black lentils', 180.00,  50.00, 25, TRUE,  TRUE),
(2, 'Veg Biryani',     'Aromatic basmati rice',     200.00,  60.00, 20, TRUE,  TRUE),
(2, 'Fish Curry',      'Coastal style fish curry',  300.00, 100.00, 22, FALSE, TRUE),
(3, 'Gulab Jamun',     'Sweet milk dumplings',       80.00,  20.00,  5, TRUE,  TRUE),
(3, 'Ice Cream',       'Vanilla scoop',              60.00,  15.00,  2, TRUE,  TRUE);

-- VERIFY
SELECT 'Tables'     AS table_name, COUNT(*) AS count FROM tables
UNION ALL SELECT 'Categories', COUNT(*) FROM menu_categories
UNION ALL SELECT 'Menu Items', COUNT(*) FROM menu_items;