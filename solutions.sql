-- Q1. E1 · Months where UPI processed more than 23 billion transactions
SELECT month, upi_volume_bn
FROM upi_monthly
WHERE upi_volume_bn > 23
ORDER BY month;

-- Q2. E2 · Average monthly credit card spend, Jan-Sep 2026 (Rs lakh crore)
SELECT ROUND(AVG(spend_inr_lakh_cr), 2) AS avg_monthly_spend_lakh_cr
FROM card_monthly;

-- Q3. E3 · The month with the highest spend per card
SELECT month,
       ROUND(spend_inr_lakh_cr * 1e12 / (cards_outstanding_mn * 1e6)) AS spend_per_card_inr
FROM card_monthly
ORDER BY spend_per_card_inr DESC
LIMIT 1;

-- Q4. E4 · Month-on-month growth in UPI volume (%)
SELECT month,
       upi_volume_bn,
       ROUND(100.0 * upi_volume_bn / LAG(upi_volume_bn) OVER (ORDER BY month) - 100, 1) AS mom_growth_pct
FROM upi_monthly
ORDER BY month;

-- Q5. E5 · Months where UPI moved more than 14.5x the value of card spend
SELECT u.month,
       ROUND(u.upi_value_inr_lakh_cr / c.spend_inr_lakh_cr, 1) AS upi_to_card_x
FROM upi_monthly u
JOIN card_monthly c ON c.month = u.month
WHERE u.upi_value_inr_lakh_cr / c.spend_inr_lakh_cr > 14.5
ORDER BY u.month;

-- Q6. E6 · Running total of cards added since January (millions)
SELECT month,
       ROUND(cards_outstanding_mn - FIRST_VALUE(cards_outstanding_mn) OVER (ORDER BY month), 2) AS added_since_jan_mn
FROM card_monthly
ORDER BY month;

-- Q7. E7 · Each issuer's share of the three issuers' combined spend, April 2026
SELECT issuer,
       ROUND(100.0 * spend_inr_cr / SUM(spend_inr_cr) OVER (), 1) AS share_of_top3_pct
FROM issuer_apr2026
ORDER BY share_of_top3_pct DESC;

-- Q8. E8 · The three months with the smallest average UPI payment
SELECT month,
       ROUND(upi_value_inr_lakh_cr * 1e12 / (upi_volume_bn * 1e9)) AS avg_ticket_inr
FROM upi_monthly
ORDER BY avg_ticket_inr
LIMIT 3;
