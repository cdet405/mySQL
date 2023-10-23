SELECT 
  s.name, 
  l.statType, 
  (
    SELECT 
      statValue 
    FROM 
      supplierWarehouseChangeLog li 
    WHERE 
      (
        li.vendorID = l.vendorID 
        AND li.tsLogged = MAX(l.tsLogged) 
        AND li.statType = 'error'
      ) 'statValue', 
      MAX(l.tsLogged) 'lastErrorTime', 
      x.lastUpdateTime, 
      DATEDIFF(
        x.lastUpdateTime, 
        CURDATE()
      ) 'daysSinceUpdate' 
    FROM 
      supplierWarehouseChangeLog l 
      JOIN supplier s USING (id) 
      LEFT JOIN(
        SELECT 
          vendorID, 
          taskID, 
          `action`, 
          MAX(tsLogged) 'lastUpdateTime' 
        FROM 
          supplierWarehouseChangeLog 
        WHERE 
          `action` = 'Apply' 
        GROUP BY 
          vendorID
      ) x ON x.vendorID = l.vendorID 
    WHERE 
      l.statType = 'Error' 
      AND s.networkInventory = 1 
    GROUP BY 
      s.name 
    HAVING 
      MAX(l.tsLogged) > x.lastUpdateTime 
      AND DATE(
        MAX(l.tsLogged)
      ) = DATE(NOW()) 
    ORDER BY 
      MAX(l.tsLogged) DESC;
