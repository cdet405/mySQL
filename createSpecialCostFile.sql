-- Create Special Cost File CD 
SET @DiscountStructure:=.1; -- Discount Percentage in Decimal Format 
SET @endDate:="2025-01-01"; -- END DATE YYYY-MM-DD ( NEEDS TO BE DAY AFTER) 
SET @TargetVendor:="TESTVENDOR"; -- vendor.mm_vendorID 
SET @TargetBrand := 123; -- insert brandID ,also (un)comment out brand join when nessesary 

USE edb;
SELECT 
	ps.vendorID,
	ps.productID,
	ROUND(IFNULL(ps.price_costoverride,ps.last_cost) * (1 - @DiscountStructure), 2) AS 'costSpecial',
	@endDate AS 'costSpecialExpireDate'
FROM productSupplier ps
JOIN products p USING (productID)
JOIN vendors v ON v.vendorID = ps.vendorID AND v.mm_VendorID = @TargetVendor
#JOIN brands b ON p.brandID = b.brandID AND b.brandID = @TargetBrand
WHERE p.nla = 'NO' AND p.kill = 'NO'
AND ROUND(IFNULL(ps.price_costoverride,ps.break_cost) * (1 - @DiscountStructure), 2) IS NOT NULL
AND ROUND(IFNULL(ps.price_costoverride,ps.break_cost) * (1 - @DiscountStructure), 2) <> 0;
