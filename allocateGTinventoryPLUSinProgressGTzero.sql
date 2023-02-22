# Report for Allocated skus > Current Inventory & In Progess > 0
# These Orders Are In House, But Not Shippable; PRIORITIZE!
USE cddb;
SELECT 
po.orderID,
cc.sku,
cc.qty,
((IFNULL(i.sellableInventory,0) + IFNULL(ex.recQty, 0)) - IFNULL(wipni.holdCount, 0) - ifnull(wipyi.holdCount,0)) 'currentInventory',
((IFNULL(i.sellableInventory,0) + IFNULL(ex.recQty, 0)) - IFNULL(wipni.holdCount, 0))  'sellableInventory',
IFNULL(wipyi.holdCount,0) 'wipyi',
IFNULL(wipni.holdCount, 0) 'wipni',
IFNULL(a.totalAllocated,0) 'allocated',
cc.qty * cc.unitpricce 'sku_price_cost',
po.subtotal 'order_price_cost',
po.firstETA,
po.currentETA,
is.lineDesccription,
b.name,
b.category
FROM purcchaseOrders po
JOIN custCart cc ON cc.orderID = po.orderID
LEFT JOIN inventory i ON i.sku = cc.sku
LEFT JOIN views.allocated a ON a.sku = cc.sku
LEFT JOIN products p ON p.sku = cc.sku
LEFT JOIN brands b ON b.brandID = p.brandID
LEFT JOIN inventoryStatus  is ON is.inventoryStatusID = cc.cli_stat_snap
LEFT JOIN (SELECT 
	         sku,
             SUM(recQty) AS 'recQty',
             wtRec
           FROM views.exceptions
           WHERE wtRec > CURDATE()
           AND distribType NOT IN ('extra')
           GROUP BY sku) ex 
		   ON ex.sku = cc.sku
LEFT JOIN (SELECT 
	          sku,
              SUM(holdCount) AS 'holdCount'
           FROM cddb.wipsku
           WHERE lotID NOT IN (5, 6, 9)
           GROUP BY sku) wipyi 
		   ON wipyi.sku = cc.sku
LEFT JOIN (SELECT 
	          sku,
              SUM(holdCount) AS 'holdCount'
           FROM cddb.wipsku
           WHERE lotID IN (5, 6, 9)
           GROUP BY sku) wipni 
		   ON wipni.sku = cc.sku
WHERE IFNULL(a.totalAllocated,0) > (ifnull(i.sellableInventory,0) + IFNULL(ex.recQty, 0)) - IFNULL(wipni.holdCount, 0) - ifnull(wipyi.holdCount,0)
AND IFNULL(wipyi.holdCount,0) +  IFNULL(wipni.holdCount, 0) > 0
AND is.inventoryStatusID IN(5, 6, 9, 17, 22)