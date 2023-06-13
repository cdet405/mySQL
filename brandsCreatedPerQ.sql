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
