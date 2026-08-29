# Analytics Engineering Fellowship
### Habeeb Adeyinka

A collection of 10 real-world analytics engineering case studies 
built with dbt and Snowflake.

## Completed Case Studies

### 01 - E-Commerce Revenue Leakage (Lumen Loom)
- **Business Problem:** Finance and Ops disagreed on revenue by $547,013 (22.85%)
- **Tools:** dbt, Snowflake
- **Models:** 4 staging, 3 intermediate, 1 mart (8 total)
- **Key Finding:** Finance counts payment capture; Ops counts order completion. 
  Gap explained by payments on uncompleted orders.
- **Net Revenue Recommended:** $2,677,054

### 02 - Ride-Hailing Marketplace Analytics (Cobalt Mobility)
- **Business Problem:** GMV vs Net Revenue gap + "active rider" definition dispute
- **Tools:** dbt, Snowflake
- **Models:** 5 staging, 3 intermediate, 3 marts (11 total)
- **Key Finding:** GMV=$983,458 vs Net Revenue=$920,633 (6.39% gap).
  CRM active riders (15,990) vs behavioral 30d active (19,204) differ by 3,214.
- **Recommended Active Rider Definition:** Completed trip in trailing 30 days

## Tech Stack
- **Transformation:** dbt Core 2.0
- **Database:** Snowflake
- **Version Control:** Git + GitHub
- **Languages:** SQL, Python, YAML

## Project Structure
