-- Q1. Spend per card each month, and its month-on-month change
SELECT month,
       ROUND(spend_inr_lakh_cr * 1e12 / (cards_outstanding_mn * 1e6)) AS spend_per_card_inr,
       ROUND(100.0 * (spend_inr_lakh_cr / cards_outstanding_mn)
             / LAG(spend_inr_lakh_cr / cards_outstanding_mn) OVER (ORDER BY month) - 100, 1) AS mom_change_pct
FROM card_monthly
ORDER BY month;

-- Q2. Net cards added each month (millions)
SELECT month,
       cards_outstanding_mn,
       ROUND(cards_outstanding_mn - LAG(cards_outstanding_mn) OVER (ORDER BY month), 2) AS net_added_mn
FROM card_monthly
ORDER BY month;

-- Q3. Months where the card base grew but spend per card fell
WITH m AS (
  SELECT month, cards_outstanding_mn,
         spend_inr_lakh_cr / cards_outstanding_mn AS ppc,
         LAG(cards_outstanding_mn) OVER (ORDER BY month) AS prev_cards,
         LAG(spend_inr_lakh_cr / cards_outstanding_mn) OVER (ORDER BY month) AS prev_ppc
  FROM card_monthly
)
SELECT month,
       ROUND(cards_outstanding_mn - prev_cards, 2) AS cards_added_mn,
       ROUND(100.0 * ppc / prev_ppc - 100, 1)      AS spend_per_card_change_pct
FROM m
WHERE cards_outstanding_mn > prev_cards AND ppc < prev_ppc
ORDER BY month;

-- Q4. Issuer ranking by spend per card, April 2026
SELECT issuer,
       ROUND(spend_inr_cr * 1e7 / (cards_outstanding_mn * 1e6)) AS spend_per_card_inr,
       spend_yoy_pct,
       RANK() OVER (ORDER BY spend_inr_cr / cards_outstanding_mn DESC) AS rank_by_spend_per_card
FROM issuer_apr2026
ORDER BY rank_by_spend_per_card;

-- Q5. UPI average ticket and UPI value versus all card spend
SELECT u.month,
       ROUND(u.upi_value_inr_lakh_cr * 1e12 / (u.upi_volume_bn * 1e9)) AS upi_avg_ticket_inr,
       ROUND(u.upi_value_inr_lakh_cr / c.spend_inr_lakh_cr, 1)          AS upi_to_card_value_x
FROM upi_monthly u
LEFT JOIN card_monthly c ON c.month = u.month
ORDER BY u.month;

-- Q6. Named complaint categories ranked, with running share (the residual 'All other grounds' is excluded)
SELECT category,
       share_pct,
       RANK() OVER (ORDER BY share_pct DESC) AS rnk,
       ROUND(SUM(share_pct) OVER (ORDER BY share_pct DESC ROWS UNBOUNDED PRECEDING), 2) AS running_share_pct
FROM ombudsman_fy25
WHERE category <> 'All other grounds'
ORDER BY rnk;
