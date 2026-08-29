# Assumptions & Tradeoffs Log
## Case Study 01: E-Commerce Revenue Leakage (Lumen Loom)
**Analyst:** Habeeb Adeyinka
**Date:** July 2026

---

## The Core Business Problem
Finance reports $2,940,566 vs Ops $2,393,553 — gap of $547,013 (22.85%).

---

## Data Quality Findings

### Finding 1: Duplicate Order IDs in RAW_ORDERS
- **What:** order_id appeared more than once
- **Decision:** Keep latest record per order_id using ROW_NUMBER() ordered by updated_at DESC
- **Tradeoff:** Order history lost. Only most recent state retained.

### Finding 2: Duplicate Refund IDs in RAW_REFUNDS
- **What:** refund_id was not unique
- **Decision:** Deduplicate by latest requested_at DESC
- **Tradeoff:** May lose earlier refund attempts.

### Finding 3: NULL Refund IDs in RAW_REFUNDS
- **What:** Some refund records had no refund_id
- **Decision:** Exclude entirely — cannot be tracked or deduplicated
- **Tradeoff:** May slightly undercount total refunds. Net revenue marginally overstated.

### Finding 4: Corrupted Timestamps in RAW_PAYMENTS
- **What:** attempted_at and processed_at show "Invalid date"
- **Decision:** Retain records but exclude timestamp columns from analysis
- **Tradeoff:** Cannot perform payment timing analysis.

### Finding 5: NULL delivered_at in RAW_SHIPPING
- **What:** Many orders have no delivery timestamp
- **Decision:** Valid data — means in transit. Use status column instead.
- **Tradeoff:** Cannot calculate delivery time for in-transit orders.

---

## Business Definition Decisions

### Decision 1: Revenue Definition
- **Finance:** payment_amount WHERE payment_status = 'succeeded'
- **Ops:** order_amount WHERE order_status = 'completed'
- **Recommended:** net_revenue = Finance revenue minus refunds = $2,677,054
- **Why:** Payment capture is reliable. Subtracting refunds gives true earned revenue.

### Decision 2: The Revenue Gap
- **Gap:** $547,013 (22.85%)
- **Root cause:** Finance counts succeeded payments on uncompleted orders
- **Recommended action:** Align both teams on net_revenue = $2,677,054

---

## Further Investigation Needed
1. Why do some payments succeed but orders never complete?
2. Are there cancelled orders with no refund record?
3. What caused timestamp corruption in RAW_PAYMENTS?
