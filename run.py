"""Builds portfolio.db from the CSVs in data/ and runs every query in queries.sql.
Run from this folder:  python run.py            (worked examples)
                       python run.py solutions.sql   (exercise answers)     (Python 3 standard library only)
Open portfolio.db afterwards in DB Browser for SQLite to explore further."""
import csv, pathlib, sqlite3

here = pathlib.Path(__file__).parent
data = here / "data"
db = here / "portfolio.db"
db.unlink(missing_ok=True)
con = sqlite3.connect(db)
con.executescript((here / "schema.sql").read_text())

def load(table, path, cols):
    rows = [[r[c] for c in cols] for r in csv.DictReader(open(path, encoding="utf-8"))]
    con.executemany(f"INSERT INTO {table} VALUES ({','.join('?' * len(cols))})", rows)

load("card_monthly", data / "card_monthly.csv", ["month", "cards_outstanding_mn", "spend_inr_lakh_cr"])
load("issuer_apr2026", data / "issuers_apr2026.csv", ["issuer", "spend_inr_cr", "cards_outstanding_mn", "spend_yoy_pct"])
load("upi_monthly", data / "upi_monthly.csv", ["month", "upi_volume_bn", "upi_value_inr_lakh_cr"])
load("ombudsman_fy25", data / "ombudsman_fy25.csv", ["category", "share_pct_fy25"])
con.commit()

def queries(name="queries.sql"):
    title, buf = None, []
    for line in (here / name).read_text().splitlines():
        if line.startswith("-- Q"):
            if title: yield title, "\n".join(buf).strip()
            title, buf = line[3:].strip(), []
        else:
            buf.append(line)
    if title: yield title, "\n".join(buf).strip()

def run_all(name="queries.sql"):
    out = []
    for title, sql in queries(name):
        cur = con.execute(sql)
        out.append((title, sql, [d[0] for d in cur.description], cur.fetchall()))
    return out

if __name__ == "__main__":
    import sys
    for title, sql, cols, rows in run_all(sys.argv[1] if len(sys.argv) > 1 else "queries.sql"):
        print(f"\n== {title}")
        print(" | ".join(cols))
        for r in rows: print(" | ".join("" if v is None else str(v) for v in r))
