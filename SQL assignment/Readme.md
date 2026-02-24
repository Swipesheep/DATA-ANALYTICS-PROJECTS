# 🩸 Blood Bank Management System — SQL Project

A full-featured **Blood Bank Management System** built entirely in **MySQL 8.0**, covering donor registration, health screening, blood inventory tracking, transfusion management, and hospital request analysis — with 17 analytical queries, a stored procedure, and two reusable views.

---

## 📌 Project Overview

This project simulates a real-world blood bank database. It is structured in three sections:

- **Schema** — 9 relational tables with primary keys, foreign keys, and constraints
- **Sample Data** — realistic donor, hospital, recipient, and transfusion records set in Kolkata
- **Analytical Queries** — 17 queries answering real operational questions (stock levels, eligibility, trends, compatibility, and more)

---

## 🗂️ Database Schema

The database `BloodBankDB` consists of 9 tables:

| Table | Description |
|---|---|
| `BloodTypes` | Reference table for all 8 blood groups |
| `Hospitals` | Registered hospitals that request blood |
| `Donors` | Donor personal details and active status |
| `DonorHealthScreening` | Health check records before each donation |
| `Donations` | Records of each donation event |
| `BloodInventory` | Current blood stock with expiry and status |
| `Recipients` | Patients registered to receive blood |
| `BloodRequests` | Hospital/recipient blood requests with urgency |
| `Transfusions` | Fulfillment records linking requests to inventory |

### Entity Relationship Summary

```
BloodTypes ◄──── Donors ────► DonorHealthScreening
                   │                    │
                   ▼                    ▼
              Donations ◄────────── (screening_id)
                   │
                   ▼
            BloodInventory
                   │
                   ▼
            Transfusions ◄──── BloodRequests ◄──── Hospitals
                                     │                  │
                               Recipients ◄─────────────┘
```

---

## 📊 Analytical Queries (Q1 – Q17)

| # | Query | Key Concepts |
|---|---|---|
| Q1 | Current blood availability by group & type | `GROUP BY`, `SUM`, `COUNT` |
| Q2 | Supply vs demand — stock gap analysis | `CTE`, `LEFT JOIN UNION RIGHT JOIN`, `COALESCE` |
| Q3 | Donors with blood-borne diseases | `CONCAT`, `CASE`, multi-condition `WHERE` |
| Q4 | Contaminated blood units in inventory | Multi-table `JOIN`, filtered `WHERE` |
| Q5 | Blood units expiring within 10 days | `BETWEEN`, `DATE_ADD`, `DATEDIFF` |
| Q6 | Donor history & eligibility check | `LEFT JOIN`, `MAX`, `DATEDIFF`, `CASE` |
| Q7 | Hospital-wise request analysis | Conditional `SUM`, `ROUND`, fulfillment rate |
| Q8 | Critical & high-urgency unfulfilled requests | `IN`, `LEFT JOIN`, urgency filter |
| Q9 | Transfusion outcome report | 5-table `JOIN`, outcome tracking |
| Q10 | Monthly donation trends | `DATE_FORMAT`, `COUNT DISTINCT`, conditional `SUM` |
| Q11 | Blood compatibility check for a recipient | `IN` list, compatibility rules |
| Q12 | Top donors by total units donated | `GROUP BY`, `SUM`, `ORDER BY` |
| Q13 | Inventory audit by status | `GROUP BY` multi-column, `SUM` |
| Q14 | Donor deferral report | `CASE` for YES/NO flags, eligibility filter |
| Q15 | Stored Procedure — `RegisterDonation` | `DELIMITER`, `IN/OUT` params, chained `INSERT` |
| Q16 | View — `vw_BloodAvailability` | `CREATE VIEW`, conditional `SUM` in `CASE` |
| Q17 | View — `vw_DonorEligibility` | Correlated subquery inside `CASE`, `LEFT JOIN` |

---

## 🔧 MySQL 8.0 Compatibility Fixes

The original script had **4 syntax errors** incompatible with MySQL. All have been fixed:

| Query | Problem | Fix Applied |
|---|---|---|
| **Q2** | `FULL OUTER JOIN` — not supported in MySQL | Replaced with `LEFT JOIN` + `UNION` + `RIGHT JOIN` |
| **Q3** | `\|\|` string concat operator — PostgreSQL syntax | Replaced with nested `CONCAT()` |
| **Q11** | `VALUES()` table constructor inside subquery | Replaced with simple `IN ('B+','B-','O+','O-')` |
| **Q12** | `GROUP BY` referencing a `SELECT` alias | Replaced alias with the full `CONCAT()` expression |

---

## 🚀 How to Run

### Prerequisites
- MySQL 8.0 or higher
- MySQL Workbench (or any MySQL client)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/blood-bank-management-sql.git
   cd blood-bank-management-sql
   ```

2. **Open MySQL Workbench** and connect to your local MySQL server

3. **Run the SQL file**
   - Go to `File → Open SQL Script`
   - Select `Bloodbank_data_sql_project_MySQL8.sql`
   - Click the ⚡ **Execute** button (or press `Ctrl + Shift + Enter`)

4. **The script will automatically:**
   - Create the `BloodBankDB` database
   - Create all 9 tables
   - Insert all sample data
   - Run all 17 analytical queries
   - Create the stored procedure and both views

### Test the Stored Procedure
```sql
CALL RegisterDonation(
    1,          -- donor_id
    14.5,       -- hemoglobin level
    118, 76,    -- blood pressure (sys, dia)
    72,         -- pulse rate
    98.4,       -- temperature (°F)
    FALSE, FALSE, FALSE, FALSE, FALSE,  -- disease flags
    'Whole Blood',   -- donation type
    'Nurse Adams',   -- collected by
    @msg             -- output message
);
SELECT @msg;
```

### Query the Views
```sql
-- Live blood availability dashboard
SELECT * FROM vw_BloodAvailability ORDER BY blood_group;

-- Donor eligibility summary
SELECT * FROM vw_DonorEligibility ORDER BY eligibility_status;
```

---

## 🩺 Blood Compatibility Reference

Used in **Q11** — change the `IN()` list to match the recipient's blood group:

| Recipient | Compatible Donor Groups |
|---|---|
| **A+** | A+, A−, O+, O− |
| **A−** | A−, O− |
| **B+** | B+, B−, O+, O− |
| **B−** | B−, O− |
| **AB+** | A+, A−, B+, B−, AB+, AB−, O+, O− *(universal recipient)* |
| **AB−** | A−, B−, AB−, O− |
| **O+** | O+, O− |
| **O−** | O− only *(universal donor)* |

---

## 📁 File Structure

```
blood-bank-management-sql/
│
└── Bloodbank_data_sql_project_MySQL8.sql   # Main SQL file (schema + data + queries)
└── README.md                               # Project documentation
```

---

## 🛠️ Tech Stack

![MySQL](https://img.shields.io/badge/MySQL-8.0-blue?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-orange)
![Workbench](https://img.shields.io/badge/Tool-MySQL%20Workbench-lightblue)

---

## 📚 Concepts Covered

- Relational database design & normalization
- Primary keys, foreign keys & referential integrity
- ENUM types & Boolean flags
- Complex multi-table JOINs (INNER, LEFT, RIGHT)
- Common Table Expressions (CTEs)
- Aggregate functions (`COUNT`, `SUM`, `MAX`, `MIN`)
- Conditional aggregation (`SUM(CASE WHEN ... END)`)
- Date functions (`CURDATE`, `DATEDIFF`, `DATE_ADD`, `DATE_FORMAT`)
- Correlated subqueries
- Stored procedures with IN/OUT parameters
- Reusable database views

---

## 👤 Author

**Your Name**
- GitHub: [@your-username](https://github.com/your-username)
- LinkedIn: [your-linkedin](https://linkedin.com/in/your-linkedin)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
