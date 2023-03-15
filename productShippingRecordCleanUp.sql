/*

This Script Removes Removes Irrelevant Product Shipping Records.

When a product-vendor relationship is dropped the shipping params remain intact
The front end will still advertise results based on now irrelevant params. 
  
*/

SET  SQL_SAFE_UPDATES = 0;
SET @db := DATABASE();
SET @db_t := CASE WHEN @db = 'edb' THEN 'tdb' ELSE CONCAT( @db, '_t' ) END;

-- Drop working table if exist
DROP TABLE IF EXISTS dev_db.ptmpProductVendorShippingRemove;
DROP TABLE IF EXISTS dev_db.ptmpProductVendorShippingRemoveTDB;

-- Create working Table for Tdb
CREATE TABLE dev_db.ptmpProductVendorShippingRemoveTDB (
	`productID` INT(10) UNSIGNED NOT NULL,
	`vendorID` INT(10) UNSIGNED NOT NULL,
	`shipFree` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`productID`, `vendorID`) USING BTREE,
	INDEX `idxVendorID` (`vendorID`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;

-- Create Working Table for edb
CREATE TABLE dev_db.ptmpProductVendorShippingRemove (
	`productID` INT(10) UNSIGNED NOT NULL,
	`vendorID` INT(10) UNSIGNED NOT NULL,
	`shipFree` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`surcharge` DECIMAL(6,2) NOT NULL DEFAULT '0.00',
	`dropShip` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`groundShipOnly` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`noShipPlus` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	`freightOnly` TINYINT(1) UNSIGNED NOT NULL DEFAULT '0',
	PRIMARY KEY (`productID`, `vendorID`) USING BTREE,
	INDEX `idxVendorID` (`vendorID`) USING BTREE
)
COLLATE='latin1_swedish_ci'
ENGINE=InnoDB
;

-- Insert records into working table EDB
-- exclude when vendorid = 0 these are parent productids to kits/pdks that are not bound to a vendor, therefor wouldnt exist in productVendor
INSERT INTO dev_db.ptmpProductVendorShippingRemove
(productID, vendorID, shipFree, surcharge, dropShip, groundShipOnly, noShipPlus, freightOnly)
SELECT
productID,
vendorID,
shipFree,
surcharge,
dropShip,
groundShipOnly,
noShipPlus,
freightOnly
FROM productVendorShipping pvs
WHERE NOT EXISTS(SELECT productID,vendorID
				FROM productVendor pv
				WHERE ( pvs.productID = pv.productID AND pvs.vendorID = pv.vendorID))
AND pvs.vendorID <> 0;


-- Insert records into working table TMS
-- exclude when vendorid = 0 these are parent productids to kits/pdks that are not bound to a vendor, therefor wouldnt exist in productVendor
INSERT INTO dev_db.ptmpProductVendorShippingRemoveTDB
(productID, vendorID, shipFree)
SELECT
productID,
vendorID,
shipFree
FROM tdb.productVendorShipping tpvs
WHERE NOT EXISTS( SELECT productID, vendorID
				FROM tdb.productVendor tpv
				WHERE (tpvs.productID = tpv.productID AND tpvs.vendorID = tpv.vendorID))
AND tpvs.vendorID <> 0;

-- Remove Records from productVendorShipping edb

DELETE productVendorShipping FROM productVendorShipping JOIN dev_db.ptmpProductVendorShippingRemove USING (productID, vendorID);

-- Remove Records from productVendorShipping Tdb

DELETE tdb.productVendorShipping FROM tdb.productVendorShipping JOIN dev_db.ptmpProductVendorShippingRemoveTDB USING (productID, vendorID);

-- Insert records in change log for edb

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'Surcharge' as field, surcharge as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'ShipFree' as field, shipFree as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'NoShipPlus' as field, noShipPlus as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'DropShip' as field, dropShip as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'GroundShipOnly' as field, groundShipOnly as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;

INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'FreightOnly' as field, freightOnly as valueOld, 'REMOVED' as valueNew, 1 as siteID
FROM dev_db.ptmpProductVendorShippingRemove;



-- Insert change log for Tdb


INSERT IGNORE INTO edb.productVendorLog (productID,vendorID,modifyDate,user,field,valueOld,valueNew,siteID)
SELECT productID,vendorID,NOW() as modifydate, 'programming' as user, 'ShipFree' as field, shipFree as valueOld, 'REMOVED' as valueNew, 2 as siteID
FROM dev_db.ptmpProductVendorShippingRemoveTDB;



-- update ts for product for cache
SET @var_updateProductTS := CONCAT("
    UPDATE ", @db, ".product
       JOIN (SELECT productID FROM dev_db.ptmpProductVendorShippingRemove UNION SELECT productID FROM dev_db.ptmpProductVendorShippingRemoveTDB) AS ts USING (productID)
    SET date_modified = NOW();
");

PREPARE updateProductTS FROM @var_updateProductTS;
EXECUTE updateProductTS;
DEALLOCATE PREPARE updateProductTS;






-- Clean Up Working Tables 

DROP TABLE IF EXISTS dev_db.ptmpProductVendorShippingRemove;
DROP TABLE IF EXISTS dev_db.ptmpProductVendorShippingRemoveTDB;
