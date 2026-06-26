-- Purpose: wedding-register schema — one table of guests for the registry.
-- The middle tier (backend API) reads/writes this; RDS MySQL holds it in AWS.

CREATE TABLE IF NOT EXISTS guests (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(120)  NOT NULL,
  address    VARCHAR(255)  NOT NULL,
  phone      VARCHAR(40)   NOT NULL,
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP
);
