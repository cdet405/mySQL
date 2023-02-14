USE cddb;
SELECT s.name,
    l.statType,
    MID(l.statValue, (INSTR(l.statValue, '->')+2),52) 'errMsg',
    MAX(l.tsLogged) 'lastErrorTime',
    x.lastUpdateTime,
    DATEDIFF(x.lastUpdateTime, CURDATE()) 'daysSinceUpdate'
FROM supplierWarehouseChangeLog l
    LEFT JOIN supplier s USING (id)
    LEFT JOIN(
        SELECT l.id,
            l.taskID,
            l.`action`,
            MAX(l.tsLogged) 'lastUpdateTime'
        FROM supplierWarehouseChangeLog l
        WHERE l.`action` = 'Apply'
        GROUP BY l.id
    ) x ON x.id = l.id
WHERE l.statType = 'Error'
    AND l.statValue NOT LIKE '%locked.'
    AND s.networkInventory = 1
GROUP BY s.name
HAVING MAX(l.tsLogged) > x.lastUpdateTime 
	 AND DATE(MAX(l.tsLogged)) = DATE(NOW())
ORDER BY MAX(l.tsLogged) DESC;