/**
 * Purpose: Wedding-registry API (the middle tier). Exposes a tiny REST surface
 *          for guests to add themselves and for the couple to list everyone.
 *          Talks to MySQL (local docker-compose in dev, RDS in AWS).
 * Author(s): John Reed
 */

import express from "express";
import cors from "cors";
import mysql from "mysql2/promise";

// Constants — all config from env so the same image runs locally and on EC2.
const PORT = process.env.PORT || 4000;
const DB = {
  host: process.env.DB_HOST || "127.0.0.1",
  port: Number(process.env.DB_PORT || 3306),
  user: process.env.DB_USER || "wedding",
  password: process.env.DB_PASSWORD || "wedding",
  database: process.env.DB_NAME || "wedding_register",
  waitForConnections: true,
  connectionLimit: 10,
};

const pool = mysql.createPool(DB);

const app = express();
app.use(cors());
app.use(express.json());

// Health check — the ALB target group hits this.
app.get("/health", (_req, res) => res.json({ ok: true }));

// List all guests (newest first).
app.get("/api/guests", async (_req, res) => {
  try {
    const [rows] = await pool.query(
      "SELECT id, name, address, phone, created_at FROM guests ORDER BY created_at DESC"
    );
    res.json(rows);
  } catch (err) {
    console.error("list guests failed...", err.message);
    res.status(500).json({ error: "could not list guests" });
  }
});

// Add a guest. Validates the three required fields, nothing fancy.
app.post("/api/guests", async (req, res) => {
  const { name, address, phone } = req.body || {};
  if (!name || !address || !phone) {
    return res.status(400).json({ error: "name, address and phone are all required" });
  }
  try {
    const [result] = await pool.query(
      "INSERT INTO guests (name, address, phone) VALUES (?, ?, ?)",
      [String(name).trim(), String(address).trim(), String(phone).trim()]
    );
    res.status(201).json({ id: result.insertId, name, address, phone });
  } catch (err) {
    console.error("add guest failed...", err.message);
    res.status(500).json({ error: "could not add guest" });
  }
});

app.listen(PORT, () => console.log(`wedding-register api listening on :${PORT}...`));
