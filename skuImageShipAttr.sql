-- identify if products are free ship and have images 
USE bi;
SELECT
  p.productID,
  CASE WHEN IFNULL(pvs.shipFree,0) = 0 THEN 'NO' ELSE 'YES' END AS 'FS',
  IFNULL(fse.freeShipEligible,'NO') 'FSE',
  IF(IFNULL(ir.pics,0) >=1 , 'YES','NO') 'Pics',
  p.velocity
FROM products p
LEFT JOIN freeShipEligible fse ON fse.productID = p.productID
LEFT JOIN brands b USING (brandID)
LEFT JOIN productVendorShipping pvs ON pvs.productID = p.productID
LEFT JOIN (
	SELECT 
	 DISTINCT 
	  i.productID,
	  COUNT(i.productID) 'pics'
	FROM images i
	GROUP BY 1 
	) ir ON ir.productID = p.productID
WHERE p.`type` = 'Kit' 
  AND p.brandID IN(1,2,3,4,5) -- <-- insert brand codes
  AND p.nfis = 'NO' 
  AND p.nla = 'NO'
ORDER BY p.velocity DESC;
