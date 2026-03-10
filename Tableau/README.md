# 📊 Customer Segmentation & Churn Analysis — Tableau Dashboard

A fully interactive Tableau Desktop dashboard project analyzing customer behavior, segmentation, and churn risk using retail order data.

---

## 📁 Dataset

**File:** `Age_group.csv`
**Rows:** 2,000 orders
**Columns:** 23 fields

| Column | Description |
|---|---|
| `order_id` | Unique order identifier |
| `customer_id` | Unique customer identifier |
| `age` / `Age_group` | Customer age and grouped bucket (18-25, 26-35, etc.) |
| `gender` | Customer gender |
| `country` | Customer country |
| `signup_date` / `last_purchase_date` | Customer lifecycle dates |
| `subscription_status` | active / paused / cancelled |
| `cancellations_count` | Number of times customer cancelled |
| `category` / `preferred_category` | Product category data |
| `unit_price` / `quantity` / `Revenue` | Order financials |
| `purchase_frequency` | How often a customer purchases |
| `Days Since Last Purchase` | Inactivity metric |
| `Customer Tenure Days` | Length of customer relationship |
| `Churn Risk Score` | Risk score from 50–100 (higher = more at risk) |
| `Month-Year` | Order date aggregated by month |

---

## 📌 Dashboards Built

### 1. 👥 Customer Segmentation Dashboard
Answers key questions about who your customers are:
- Which age group generates the most revenue?
- How are genders distributed across age groups?
- What does each age group prefer to buy?
- Which age groups are at risk of cancelling?

**Charts included:**
- Revenue by Age Group (Bar Chart)
- Customer Count by Age Group & Gender (Stacked Bar)
- Preferred Category by Age Group (Heatmap)
- Subscription Status by Age Group (Stacked Bar)

---

### 2. 🔴 Churn & Retention Analysis Dashboard
Identifies customers at risk of leaving:
- Which age groups have the highest churn risk?
- Does cancellation history predict churn?
- Which countries need retention attention?
- Are inactive customers already churning?

**Charts included:**
- Churn Risk by Age Group (Bar Chart)
- Cancellations vs. Churn Risk Score (Scatter Plot with Trend Line)
- Churn Risk by Country (Map)
- Inactivity by Subscription Status (Bar Chart)
- Churn Score Distribution (Histogram)

---

## 🧮 Calculated Fields

### Churn Risk Category
Groups the churn score into Low / Medium / High tiers:
```
IF [Churn Risk Score] <= 60 THEN "Low Risk"
ELSEIF [Churn Risk Score] <= 80 THEN "Medium Risk"
ELSE "High Risk"
END
```

### Active Customers
```
SUM(IF [Subscription Status] = "active" THEN 1 ELSE 0 END)
```

### Cancelled Customers
```
SUM(IF [Subscription Status] = "cancelled" THEN 1 ELSE 0 END)
```

### Paused Customers
```
SUM(IF [Subscription Status] = "paused" THEN 1 ELSE 0 END)
```

---

## 🛠️ Tools Used

- **Tableau Desktop** — Dashboard building and visualization
- **CSV / Excel** — Raw data source

---

## 🚀 How to Use

1. Clone or download this repository
2. Open **Tableau Desktop**
3. Connect to `Age_group.csv` via **Data → Text File**
4. Open the `.twbx` workbook file *(if included)*
5. Explore the **Customer Segmentation** and **Churn & Retention** dashboard tabs
6. Use the interactive filters to slice data by Age Group, Country, or Churn Risk

---

## 💡 Key Insights You Can Derive

- Identify your **highest value age segments** by revenue
- Spot **churn hotspots** by country and age group
- Understand the relationship between **inactivity and cancellation**
- Compare **gender preferences** across product categories
- Track **subscription health** across your entire customer base

---

## 📂 Repository Structure

```
📦 tableau-customer-analysis
 ┣ 📄 Age_group.csv          # Raw dataset
 ┣ 📄 README.md              # Project documentation
 ┗ 📊 dashboard.twbx         # Tableau packaged workbook (if exported)
```

---

## 🙋 Author

Built as a beginner Tableau project to practice data visualization and customer analytics.

Feel free to fork, explore, and build on top of it!

---

## 📜 License

This project is open source and available under the [MIT License](LICENSE).
