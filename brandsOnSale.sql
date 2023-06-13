-- brands on sale + product count
USE bi;
SELECT 
  b.name 'brand',
  COUNT(web.productID) 'product_count'
FROM websitePricing web
LEFT JOIN product p USING (productID)
LEFT JOIN brand b USING (brandID)
WHERE (web.onsale = 'YES' OR (web.saleInd + web.saleInd2) > 0 )
	AND p.nla = 'NO'
	AND p.stockstatus = 'YES'
	AND p.nfis = 'NO'
GROUP BY 1
ORDER BY 2 DESC;
