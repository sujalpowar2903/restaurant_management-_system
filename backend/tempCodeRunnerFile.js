const express = require('express');
const mysql   = require('mysql2');
const cors    = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host:     'localhost',
  user:     'root',
  password: 'sujal2903',
  database: 'restaurant_management'
});

db.connect(err => {
  if (err) { console.log("DB Error:", err); return; }
  console.log("MySQL Connected");
});


// ───────── MENU (includes category_name) ─────────
app.get('/menu', (req, res) => {
  const sql = `
    SELECT
      mi.item_id,
      mi.item_name,
      mi.description,
      mi.price,
      mi.cost_price,
      mi.preparation_time,
      mi.is_vegetarian,
      mi.is_available,
      mi.image_url,
      COALESCE(mc.category_name, 'General') AS category_name
    FROM menu_items mi
    LEFT JOIN menu_categories mc ON mi.category_id = mc.category_id
    WHERE mi.is_available = 1
  `;
  db.query(sql, (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(data);
  });
});


// ───────── PLACE ORDER ─────────
app.post('/order', (req, res) => {
  const { table_id, item_id, quantity } = req.body;

  // Step 1: get item price
  db.query(
    "SELECT price FROM menu_items WHERE item_id = ?",
    [item_id],
    (err, rows) => {
      if (err || rows.length === 0)
        return res.status(400).json({ error: "Item not found" });

      const price    = parseFloat(rows[0].price);
      const qty      = parseInt(quantity) || 1;
      const subtotal = price * qty;
      const tax      = parseFloat((subtotal * 0.05).toFixed(2));
      const total    = parseFloat((subtotal + tax).toFixed(2));

      // Step 2: create order row with all totals at once
      db.query(
        `INSERT INTO orders
           (table_id, subtotal, tax_amount, total_amount, status)
         VALUES (?, ?, ?, ?, 'pending')`,
        [table_id, subtotal, tax, total],
        (err2, result) => {
          if (err2) return res.status(500).json({ error: err2.message });

          const order_id = result.insertId;

          // Step 3: insert order item with unit_price
          db.query(
            `INSERT INTO order_items
               (order_id, item_id, quantity, unit_price)
             VALUES (?, ?, ?, ?)`,
            [order_id, item_id, qty, price],
            (err3) => {
              if (err3) return res.status(500).json({ error: err3.message });

              res.json({ message: "Order placed", order_id, subtotal, tax, total });
            }
          );
        }
      );
    }
  );
});


// ───────── GET ORDERS (recalculates if unit_price = 0) ─────────
app.get('/orders', (req, res) => {
  const sql = `
    SELECT
      o.order_id,
      o.table_id,
      o.status,
      o.subtotal,
      o.tax_amount,
      o.total_amount,
      oi.quantity,
      oi.unit_price,
      mi.item_name,
      mi.price AS menu_price
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items  mi ON oi.item_id  = mi.item_id
    ORDER BY o.order_id DESC
  `;

  db.query(sql, (err, rows) => {
    if (err) return res.status(500).json({ error: err.message });

    // Fix any rows where unit_price or total_amount was stored as 0
    const fixed = rows.map(r => {
      const up      = parseFloat(r.unit_price)   > 0
                        ? parseFloat(r.unit_price)
                        : parseFloat(r.menu_price) || 0;
      const qty     = parseInt(r.quantity)        || 1;
      const subtotal= parseFloat((up * qty).toFixed(2));
      const tax     = parseFloat(r.tax_amount)    > 0
                        ? parseFloat(r.tax_amount)
                        : parseFloat((subtotal * 0.05).toFixed(2));
      const total   = parseFloat(r.total_amount)  > 0
                        ? parseFloat(r.total_amount)
                        : parseFloat((subtotal + tax).toFixed(2));

      return {
        order_id:     r.order_id,
        table_id:     r.table_id,
        status:       r.status,
        item_name:    r.item_name,
        quantity:     qty,
        unit_price:   up,
        subtotal:     subtotal,
        tax_amount:   tax,
        total_amount: total
      };
    });

    res.json(fixed);
  });
});


// ───────── UPDATE STATUS ─────────
app.patch('/order/:id/status', (req, res) => {
  const { id }     = req.params;
  const { status } = req.body;

  db.query(
    "UPDATE orders SET status = ? WHERE order_id = ?",
    [status, id],
    (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ message: "Updated" });
    }
  );
});


// ───────── TABLES ─────────
app.get('/tables', (req, res) => {
  db.query("SELECT * FROM tables ORDER BY table_number", (err, data) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(data);
  });
});


app.listen(5000, () => {
  console.log("Server running on http://localhost:5000");
});