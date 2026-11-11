-- Portfolio data model: three public datasets, one table each.
CREATE TABLE card_monthly (
  month                 TEXT PRIMARY KEY,   -- 'YYYY-MM'
  cards_outstanding_mn  REAL NOT NULL,      -- millions of credit cards
  spend_inr_lakh_cr     REAL NOT NULL       -- monthly spend, Rs lakh crore (1 = Rs 10^12)
);
CREATE TABLE issuer_apr2026 (
  issuer                TEXT PRIMARY KEY,
  spend_inr_cr          REAL NOT NULL,      -- Rs crore (1 = Rs 10^7)
  cards_outstanding_mn  REAL NOT NULL,
  spend_yoy_pct         REAL
);
CREATE TABLE upi_monthly (
  month                 TEXT PRIMARY KEY,
  upi_volume_bn         REAL NOT NULL,      -- billions of transactions
  upi_value_inr_lakh_cr REAL NOT NULL
);
CREATE TABLE ombudsman_fy25 (
  category              TEXT PRIMARY KEY,
  share_pct             REAL NOT NULL       -- share of complaints at RBI Ombudsman offices
);
