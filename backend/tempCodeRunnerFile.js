const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: 'sujal2903',  // ← change this to your MySQL password
  database: 'restaurant_management'
});

db.connect((err) => {
  if (err) {
    process.stdout.write('DB Error: ' + err.message + '\n');
    return;
  }
  process.stdout.write('Connected to MySQL\n');
});

app.get('/menu', (req, res) => {
  db.query(
    'SELECT item_id, item_name, price FROM menu_items WHERE is_available = 1',
    (err, results) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json(results);
    }
  );
});

app.post('/order', (req, res) => {
  const { table_id, item_id, quantity } = req.body;
  db.query(
    "INSERT INTO orders (table_id, order_type, status) VALUES (?, 'dine-in', 'pending')",
    [table_id],
    (err, result) => {
      if (err) return res.status(500).json({ error: err.message });
      const order_id = result.insertId;
      db.query('SELECT price FROM menu_items WHERE item_id = ?', [item_id], (err2, items) => {
        if (err2 || items.length === 0)
          return res.status(400).json({ error: 'Item not found' });
        const unit_price = items[0].price;
        db.query(
          'INSERT INTO order_items (order_id, item_id, quantity, unit_price) VALUES (?, ?, ?, ?)',
          [order_id, item_id, quantity, unit_price],
          (err3) => {
            if (err3) return res.status(500).json({ error: err3.message });
            res.json({ message: 'Order #' + order_id + ' placed!' });
          }
        );
      });
    }
  );
});

app.get('/orders', (req, res) => {
  const sql = `
    SELECT o.order_id, o.table_id, o.status, o.total_amount,
           mi.item_name, oi.quantity
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items mi  ON oi.item_id = mi.item_id
    ORDER BY o.created_at DESC
  `;
  db.query(sql, (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results);
  });
});

app.listen(5000, () => {
  process.stdout.write('Server running on http://localhost:5000\n');
});