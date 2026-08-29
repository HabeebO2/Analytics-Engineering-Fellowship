# Assumptions & Tradeoffs Log
## Case Study 02: Ride-Hailing Marketplace Analytics (Cobalt Mobility)
**Analyst:** Habeeb Adeyinka
**Date:** July 2026

---

## Business Context
Cobalt Mobility raising Series C. Three teams disagree on GMV,
revenue, and active rider definitions.

---

## Key Numbers
- GMV: $983,458
- Net Revenue: $920,633
- Gap: $62,825 (6.39%)
- Cancellation Rate: 16.48%
- Fraud Rate: 2.75%
- Total Riders: 20,000
- CRM Active: 15,990
- Behavioral Active 30d: 19,204

---

## Data Quality Findings

### Finding 1: Duplicate Driver IDs
- **What:** DRIVER_ID reused when churned driver re-onboards
- **Decision:** Keep latest record per driver_id ordered by onboarded_at DESC
- **Tradeoff:** Driver history from previous stint is lost

### Finding 2: Double-logged Payment Captures
- **What:** Webhook fired twice for same payment — duplicates in RAW_PAYMENTS
- **Decision:** Keep only captured status, latest per trip_id
- **Tradeoff:** Earlier payment attempts not visible in staging

### Finding 3: Over-attributed Driver Incentives
- **What:** Same trip appears on multiple campaign lines
- **Decision:** Deduplicate within same driver_id + trip_id + incentive_type
- **Tradeoff:** Driver can legitimately earn multiple bonus types per trip — preserved

### Finding 4: Corrupted Timestamps in RAW_TRIPS
- **What:** requested_at shows "Invalid date" for most records
- **Decision:** Retain records but flag timestamp as unreliable
- **Tradeoff:** 30d vs 90d active rider windows return identical results (19,204)
  — time-based analysis unreliable until source system fixed

### Finding 5: CRM Active Flag Unreliable
- **What:** 3,214 riders completed trips in 30d but are marked non-active in CRM
- **Decision:** Do not use CRM flag as primary active definition
- **Tradeoff:** CRM (15,990) shows fewer active than behavioral (19,204)

---

## Business Definition Decisions

### Decision 1: Active Rider Definition
- **CRM definition:** account_status = 'active' → 15,990 riders
- **Behavioral 30d:** completed trip in last 30 days → 19,204 riders
- **Recommended:** is_active_30d (19,204) — reflects real platform usage
- **Why:** CRM flag not updated reliably. Behavioral metric is trustworthy.

### Decision 2: GMV vs Net Revenue
- **GMV:** All gross fares at trip request time — Growth's metric
- **Net Revenue:** Completed trip fares only — Finance's metric
- **Gap:** $62,825 (6.39%) explained by cancellations + fraud
- **Recommended:** Net Revenue as primary business metric

### Decision 3: Fraud Handling
- **Decision:** Fraudulent trips excluded from net revenue
- **Decision:** Driver earnings from fraudulent trips retained
- **Why:** Drivers not responsible for fraud they didn't commit

### Decision 4: Currency
- **Finding:** Payments in both USD (60%) and GBP (40%)
- **Decision:** Retained original currency in staging
- **Tradeoff:** Cross-currency revenue comparison requires exchange rate assumption

---

## Further Investigation Needed
1. Fix timestamp corruption in RAW_TRIPS source system
2. Update CRM active flag logic to reflect behavioral activity
3. Investigate 3,214 riders active behaviorally but inactive in CRM
4. Determine official GBP to USD exchange rate for unified reporting
