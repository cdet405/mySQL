-- Counts Earliest Date a Brand had a sku associated with it
-- min create date on brands table is misleading as brands can be created but not actually in use

USE bi; 
SELECT 
  b.name BRAND,
  YEAR(p.date_added) YR,
  QUARTER(DATE(MIN(p.date_added))) Q
FROM products p
LEFT JOIN brands b USING (brandID) 
GROUP BY 
  1
ORDER BY 
  2 ASC, 3 ASC
